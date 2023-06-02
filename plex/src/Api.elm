module Api exposing
    ( getAccount
    , getContinueWatching
    , getContinueWatchingTask
    , getLibraries
    , getLibrariesTask
    , getLibrary
    , getLibraryRecentlyAdded
    , getLibraryTask
    , getMetadata
    , getMetadataChildren
    , getResources
    , getSections
    , getSettings
    , getSubtitleUrl
    , httpJsonBodyResolver
    , playerTimeline
    , scanLibrary
    , searchSubtitle
    , selectSubtitle
    , sendDecision
    , signIn
    , transcodedImageUrl
    , videoUri
    )

import Client exposing (Client)
import Dto exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import ReactNative.Platform as Platform
import Task exposing (Task)
import Url
import Utils exposing (maybeEmptyList, maybeEmptyString, maybeFalse, maybeFloatZero, maybeZero)


httpJsonBodyResolver : Decoder a -> Http.Response String -> Response a
httpJsonBodyResolver decoder resp =
    case resp of
        Http.GoodStatus_ m s ->
            Decode.decodeString decoder
                (if String.isEmpty s then
                    "\"\""

                 else
                    s
                )
                |> Result.mapError (Decode.errorToString >> Http.BadBody)

        Http.BadUrl_ s ->
            Err (Http.BadUrl s)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ m s ->
            Decode.decodeString decoder s
                -- just trying; if our decoder understands the response body, great
                |> Result.mapError (\_ -> Http.BadStatus m.statusCode)


clientRequestUrl : String -> Client -> String
clientRequestUrl path { id, serverAddress, token } =
    serverAddress
        ++ path
        ++ (if String.contains "?" path then
                "&"

            else
                "?"
           )
        ++ (if String.isEmpty token then
                ""

            else
                "X-Plex-Token=" ++ token
           )
        ++ (if String.isEmpty id then
                ""

            else
                "&X-Plex-Client-Identifier=" ++ id
           )


clientGetJsonTask : Decoder a -> String -> Client -> Task Http.Error a
clientGetJsonTask decoder path client =
    Http.task
        { url = clientRequestUrl path client
        , method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| httpJsonBodyResolver decoder
        , timeout = Just 15000
        }


clientPostJsonTask : Value -> Decoder a -> String -> Client -> Task Http.Error a
clientPostJsonTask body decoder path client =
    Http.task
        { url = clientRequestUrl path client
        , method = "POST"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.jsonBody body
        , resolver = Http.stringResolver <| httpJsonBodyResolver decoder
        , timeout = Just 15000
        }


clientPutTask : Maybe Value -> Decoder a -> String -> Client -> Task Http.Error a
clientPutTask body decoder path client =
    Http.task
        { url = clientRequestUrl path client
        , method = "PUT"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Maybe.withDefault Http.emptyBody <| Maybe.map Http.jsonBody body
        , resolver = Http.stringResolver <| httpJsonBodyResolver decoder
        , timeout = Just 15000
        }


clientGetJson : Decoder a -> String -> (Response a -> msg) -> Client -> Cmd msg
clientGetJson decoder path tagger client =
    Http.request
        { url = clientRequestUrl path client
        , method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.emptyBody
        , expect = Http.expectJson tagger decoder
        , timeout = Just 15000
        , tracker = Nothing
        }


clientPostJson : Decoder a -> String -> (Response a -> msg) -> Client -> Cmd msg
clientPostJson decoder path tagger client =
    Http.request
        { url = clientRequestUrl path client
        , method = "POST"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.emptyBody
        , expect = Http.expectJson tagger decoder
        , timeout = Just 15000
        , tracker = Nothing
        }


getLibraries : (Response (List Library) -> msg) -> Client -> Cmd msg
getLibraries =
    clientGetJson librariesDecoder "/library/sections"


getLibrariesTask : Client -> Task Http.Error (List Library)
getLibrariesTask =
    clientGetJsonTask librariesDecoder "/library/sections"


getSections : (Response (List Section) -> msg) -> Client -> Cmd msg
getSections =
    clientGetJson sectionsDecoder "/hubs"


getContinueWatching : (Response (List Metadata) -> msg) -> Client -> Cmd msg
getContinueWatching =
    clientGetJson metadataListDecoder "/hubs/home/continueWatching"


getContinueWatchingTask : Client -> Task Http.Error (List Metadata)
getContinueWatchingTask =
    clientGetJsonTask metadataListDecoder "/hubs/home/continueWatching"


getLibraryRecentlyAdded : String -> (Response Section -> msg) -> Client -> Cmd msg
getLibraryRecentlyAdded key =
    clientGetJson firstSectionDecoder <| "/hubs/promoted?excludeContinueWatching=1&count=12&contentDirectoryID=" ++ key


getMetadata : String -> Client -> Task Http.Error Metadata
getMetadata key =
    clientGetJsonTask (Decode.at [ "MediaContainer", "Metadata" ] <| Decode.index 0 <| metadataDecoder) ("/library/metadata/" ++ key)


getMetadataChildren : String -> Client -> Task Http.Error (List Metadata)
getMetadataChildren key =
    clientGetJsonTask metadataListDecoder <| "/library/metadata/" ++ key ++ "/children"


getLibrary : String -> (Response (List Metadata) -> msg) -> Client -> Cmd msg
getLibrary key =
    clientGetJson metadataListDecoder <| "/library/sections/" ++ key ++ "/all"


getLibraryTask : String -> Client -> Task Http.Error (List Metadata)
getLibraryTask key =
    clientGetJsonTask metadataListDecoder <| "/library/sections/" ++ key ++ "/all"


getAccount : (Response Account -> msg) -> Client -> Cmd msg
getAccount =
    clientGetJson accountDecoder "/accounts"


playerTimeline : TimelineRequest -> (Response TimelineResponse -> msg) -> Client -> Cmd msg
playerTimeline { ratingKey, state, time, duration } tagger client =
    let
        uri =
            "/:/timeline"
                ++ ("?ratingKey=" ++ ratingKey)
                ++ ("&key=%2Flibrary%2Fmetadata%2F" ++ ratingKey)
                ++ ("&state=" ++ state)
                ++ ("&time=" ++ String.fromInt time)
                ++ ("&duration=" ++ String.fromInt duration)
                ++ ("&X-Plex-Client-Identifier=" ++ client.id)
    in
    clientGetJson timelineResponseDecoder uri tagger client


getSettings : (Response (List Setting) -> msg) -> Client -> Cmd msg
getSettings =
    clientGetJson settingsDecoder "/settings"


transcodedImageUrl : String -> Float -> Float -> Client -> String
transcodedImageUrl thumb width height client =
    -- http://192.168.0.104:32400/photo/:/transcode?X-Plex-Token=gCyFJ_16fpxudt8LGx72&X-Plex-Client-Identifier=vh9igc3l3t8x341wh6glmm30&width=300&height=450&url=%2Flibrary%2Fmetadata%2F78%2Fthumb%2F1684870349
    clientRequestUrl "/photo/:/transcode" client
        ++ ("&width=" ++ String.fromFloat width)
        ++ ("&height=" ++ String.fromFloat height)
        ++ ("&url=" ++ Url.percentEncode thumb)


signIn : Client -> Task Http.Error SignInResponse
signIn client =
    let
        body =
            Encode.object
                [ ( "login", Encode.string client.email )
                , ( "password", Encode.string client.password )
                ]
    in
    clientPostJsonTask body siginResponseDecoder "/users/signin" client


getResources : Client -> Task Http.Error (List Resource)
getResources =
    clientGetJsonTask (Decode.list resourceDecoder) "/resources"


selectSubtitle : Int -> Int -> Client -> Task Http.Error ()
selectSubtitle partId subtitleStreamId client =
    clientPutTask Nothing
        (Decode.succeed ())
        ("/library/parts/"
            ++ String.fromInt partId
            ++ "?allParts=1"
            ++ ("&X-Plex-Token=" ++ client.token)
            ++ ("&subtitleStreamID=" ++ String.fromInt subtitleStreamId)
        )
        client


searchSubtitle : String -> String -> String -> (Response (List MediaStream) -> msg) -> Client -> Cmd msg
searchSubtitle key language title =
    clientGetJson (Decode.at [ "MediaContainer", "Stream" ] (Decode.list streamDecoder)) <|
        "/library/metadata/"
            ++ key
            ++ "/subtitles?"
            ++ ("language=" ++ Url.percentEncode language)
            ++ (if String.isEmpty title then
                    ""

                else
                    "&title=" ++ Url.percentEncode title
               )


scanLibrary : String -> Client -> Task Http.Error ()
scanLibrary key =
    clientGetJsonTask (Decode.succeed ()) <|
        "/library/sections/"
            ++ key
            ++ "/refresh"


sendDecision newSession ratingKey sessionId tagger client =
    let
        path =
            -- I don't actaully understand why it is called `/decision`
            -- The parameters seems similiar to video uri
            "/video/:/transcode/universal/decision"
                ++ ("?path=%2Flibrary%2Fmetadata%2F" ++ ratingKey)
                ++ "&hasMDE=1"
                ++ "&mediaIndex=0"
                ++ "&partIndex=0"
                ++ "&protocol=dash"
                ++ "&fastSeek=1"
                ++ "&directPlay=0"
                ++ "&directStream=1"
                ++ "&subtitleSize=100"
                ++ "&audioBoost=100"
                ++ "&location=lan"
                ++ "&addDebugOverlay=0"
                ++ "&autoAdjustQuality=0"
                ++ "&directStreamAudio=1"
                ++ "&mediaBufferSize=102400"
                ++ "&subtitles=auto"
                ++ "&Accept-Language=en"
                ++ "&X-Plex-Client-Profile-Extra=add-limitation%28scope%3DvideoCodec%26scopeName%3Dhevc%26type%3DupperBound%26name%3Dvideo.bitDepth%26value%3D10%26replace%3Dtrue%29%2Bappend-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26protocol%3Ddash%26videoCodec%3Dhevc%29%2Badd-limitation%28scope%3DvideoTranscodeTarget%26scopeName%3Dhevc%26scopeType%3DvideoCodec%26context%3Dstreaming%26protocol%3Ddash%26type%3Dmatch%26name%3Dvideo.colorTrc%26list%3Dbt709%7Cbt470m%7Cbt470bg%7Csmpte170m%7Csmpte240m%7Cbt2020-10%7Csmpte2084%26isRequired%3Dfalse%29%2Bappend-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%26protocol%3Ddash%29"
                --++ "&X-Plex-Client-Profile-Extra=append-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%252Cac3%252Ceac3%26protocol%3Ddash%29"
                ++ "&X-Plex-Incomplete-Segments=1"
                ++ "&X-Plex-Product=Plex%20Web"
                ++ "&X-Plex-Version=4.87.2"
                ++ "&X-Plex-Platform=Safari"
                ++ "&X-Plex-Platform-Version=109.0"
                ++ "&X-Plex-Features=external-media%2Cindirect-media%2Chub-style-list"
                ++ "&X-Plex-Model=bundled"
                ++ (if Platform.os == "ios" then
                        "&X-Plex-Device=OSX"

                    else if Platform.os == "android" then
                        "&X-Plex-Device=android"

                    else
                        ""
                   )
                ++ "&X-Plex-Device-Name=Safari"
                --++ "&X-Plex-Device-Screen-Resolution=980x1646%2C393x852"
                ++ ("&X-Plex-Device-Screen-Resolution=" ++ String.fromFloat client.screenMetrics.width ++ "x" ++ String.fromFloat client.screenMetrics.height)
                ++ "&X-Plex-Language=en"
                ++ ("&X-Plex-Session-Identifier=" ++ sessionId)
                ++ ("&session=" ++ newSession)
    in
    clientGetJson (Decode.succeed ()) path tagger client



-- curl -H "Accept: application/json" http://192.168.199.103:32400/library/metadata/592/subtitles\?language\=zh\&title\=Bullet%20Train\&X-Plex-Client-Identifier\=m5h290oc8id9sl4356od4k9y\&X-Plex-Token\=hoSG7jeEsYDMQnstqnzP
--sendPlayQueues client metadata =
--    let
--        path =
--            "/playQueues?type=video"
--                ++ "&continuous=1"
--                ++ ("&uri=server%3A%2F%2Fefdfde8153949a9b7ae2f271a6e32db10925b669%2Fcom.plexapp.plugins.library%2Flibrary%2Fmetadata%2F" ++ metadata.ratingKey)
--                ++ "&repeat=0"
--                ++ "&own=1"
--                ++ "&includeChapters=1"
--                ++ "&includeMarkers=1"
--                ++ "&includeGeolocation=1"
--                ++ "&includeExternalMedia=1"
--                ++ "&X-Plex-Product=Plex%20Web"
--                ++ "&X-Plex-Version=4.100.1"
--                ++ "&X-Plex-Platform=Chrome"
--                ++ "&X-Plex-Platform-Version=110.0"
--                ++ "&X-Plex-Features=external-media%2Cindirect-media%2Chub-style-list"
--                ++ "&X-Plex-Model=bundled"
--                ++ "&X-Plex-Device=OSX"
--                ++ "&X-Plex-Device-Name=Chrome"
--                ++ "&X-Plex-Device-Screen-Resolution=1492x407%2C1728x1117"
--                ++ "&X-Plex-Language=en"
--                ++ "&X-Plex-Drm=none"
--                ++ "&X-Plex-Text-Format=plain"
--                ++ "&X-Plex-Provider-Version=5.1"
--    in
--    Api.clientPostJson (Decode.succeed ()) path (always <| GotPlayQueues metadata) client


getSubtitleUrl client ratingKey session sessionId =
    clientRequestUrl "/video/:/transcode/universal/subtitles" client
        ++ ("&hasMDE=1&path=%2Flibrary%2Fmetadata%2F" ++ ratingKey)
        ++ "&mediaIndex=0"
        ++ "&partIndex=0"
        ++ "&protocol=dash"
        ++ "&fastSeek=1"
        ++ "&directPlay=0"
        ++ "&directStream=1"
        ++ "&subtitleSize=100"
        ++ "&audioBoost=100"
        ++ "&location=lan"
        ++ "&addDebugOverlay=0"
        ++ "&autoAdjustQuality=0"
        ++ "&directStreamAudio=1"
        ++ "&mediaBufferSize=102400"
        ++ "&subtitles=auto"
        ++ "&Accept-Language=en"
        ++ "&X-Plex-Client-Profile-Extra=append-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%252Cac3%252Ceac3%26protocol%3Dhls%29"
        ++ "&X-Plex-Incomplete-Segments=1"
        ++ "&X-Plex-Product=Plex%20Web"
        ++ "&X-Plex-Version=4.87.2"
        ++ "&X-Plex-Platform=Safari"
        ++ "&X-Plex-Platform-Version=605.1"
        ++ "&X-Plex-Features=external-media%2Cindirect-media%2Chub-style-list"
        ++ "&X-Plex-Model=bundled"
        ++ "&X-Plex-Device=OSX"
        ++ "&X-Plex-Device-Name=Safari"
        --++ "&X-Plex-Device-Screen-Resolution=980x1646%2C393x852"
        ++ ("&X-Plex-Device-Screen-Resolution=" ++ String.fromFloat client.screenMetrics.width ++ "x" ++ String.fromFloat client.screenMetrics.height)
        ++ "&X-Plex-Language=en"
        ++ ("&X-Plex-Session-Identifier=" ++ sessionId)
        ++ ("&session=" ++ session)


videoUri : String -> String -> Metadata -> Client -> String
videoUri session sessionId metadata client =
    clientRequestUrl "/video/:/transcode/universal/start.mpd" client
        ++ ("&path=%2Flibrary%2Fmetadata%2F" ++ metadata.ratingKey)
        ++ "&hasMDE=1"
        ++ "&mediaIndex=0"
        ++ "&partIndex=0"
        ++ "&protocol=dash"
        ++ "&fastSeek=1"
        ++ "&directPlay=0"
        ++ "&directStream=1"
        ++ "&subtitleSize=100"
        ++ "&audioBoost=100"
        ++ "&location=lan"
        ++ "&addDebugOverlay=0"
        ++ "&autoAdjustQuality=0"
        ++ "&directStreamAudio=1"
        ++ "&mediaBufferSize=102400"
        ++ "&subtitles=auto"
        ++ "&Accept-Language=en"
        --++ "&X-Plex-Client-Profile-Extra=append-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%252Cac3%252Ceac3%26protocol%3Ddash%29"
        ++ "&X-Plex-Client-Profile-Extra=add-limitation%28scope%3DvideoCodec%26scopeName%3Dhevc%26type%3DupperBound%26name%3Dvideo.bitDepth%26value%3D10%26replace%3Dtrue%29%2Bappend-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26protocol%3Ddash%26videoCodec%3Dhevc%29%2Badd-limitation%28scope%3DvideoTranscodeTarget%26scopeName%3Dhevc%26scopeType%3DvideoCodec%26context%3Dstreaming%26protocol%3Ddash%26type%3Dmatch%26name%3Dvideo.colorTrc%26list%3Dbt709%7Cbt470m%7Cbt470bg%7Csmpte170m%7Csmpte240m%7Cbt2020-10%7Csmpte2084%26isRequired%3Dfalse%29%2Bappend-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%26protocol%3Ddash%29"
        ++ "&X-Plex-Incomplete-Segments=1"
        ++ "&X-Plex-Product=Plex%20Web"
        ++ "&X-Plex-Version=4.87.2"
        ++ "&X-Plex-Platform=Safari"
        ++ "&X-Plex-Platform-Version=605.1"
        ++ "&X-Plex-Features=external-media%2Cindirect-media%2Chub-style-list"
        ++ "&X-Plex-Model=bundled"
        ++ (if Platform.os == "ios" then
                "&X-Plex-Device=OSX"

            else if Platform.os == "android" then
                "&X-Plex-Device=android"

            else
                ""
           )
        ++ "&X-Plex-Device-Name=Safari"
        --++ "&X-Plex-Device-Screen-Resolution=1479x549%2C1728x1117"
        --++ "&X-Plex-Device-Screen-Resolution=980x1646%2C393x852"
        ++ ("&X-Plex-Device-Screen-Resolution=" ++ String.fromFloat client.screenMetrics.width ++ "x" ++ String.fromFloat client.screenMetrics.height)
        ++ "&X-Plex-Language=en"
        ++ ("&X-Plex-Session-Identifier=" ++ sessionId)
        ++ ("&session=" ++ session)
