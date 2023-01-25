module Api exposing (Account, Client, Connection, Country, Director, Genre, Guid, Library, Location, Media, MediaPart, Metadata, Rating, Resource, Role, Section, Setting, SignInResponse, TimelineRequest, TimelineResponse, Writer, accountDecoder, clientGetJson, clientGetJsonTask, clientRequestUrl, firstAccountWithName, getAccount, getContinueWatching, getLibraries, getLibrary, getLibraryRecentlyAdded, getMetadata, getMetadataChildren, getResources, getSections, getSettings, httpJsonBodyResolver, initialClient, initialLibrary, initialMetadata, librariesDecoder, libraryDecoder, metadataDecoder, metadataListDecoder, playerTimeline, sectionsDecoder, settingsDecoder, signIn, timelineResponseDecoder, transcodedImageUrl)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Media exposing (mediaDecoder, streamDecoder)
import Task exposing (Task)
import Url
import Utils exposing (maybeEmptyList, maybeEmptyString, maybeFalse, maybeFloatZero, maybeZero)


type alias Library =
    { allowSync : Bool -- 1 - allow the items in the to be synced. 0 - do not allow the items in the library to be synced.
    , art : String -- The background artwork used to represent the library.
    , composite : String -- The composite image associated with the library.
    , filters : Bool -- 1 - allow library filters. 0 - do no allow library filters.
    , refreshing : Bool -- 1 - the library is refreshing the metadata. 0 - the library is not refreshing the metadata.
    , thumb : String -- The thumbnail for the library.
    , key : String -- The relative URL of the information for the library.
    , typ : String -- The type of item represented by this Directory element.
    , title : String -- The name of the library.
    , agent : String -- The agent used to set the metadata for the items in the library.
    , scanner : String -- The name of the scanner used to scan the library.
    , language : String -- The two-character language for the library.
    , uuid : String -- Unique identifier for the library.
    , updatedAt : Int -- The date and time the library was updated in the library.
    , createdAt : Int -- The date and time when the library was created.
    , scannedAt : Int -- The date and time when the library was last scanned
    , content : Bool
    , directory : Bool
    , contentChangedAt : Int -- The date and time when the library content was last changed.
    , hidden : Bool -- 1 - the library is hidden. 0 - the library is not hidden.
    , location : List Location
    }


initialLibrary : Library
initialLibrary =
    { allowSync = False
    , art = ""
    , composite = ""
    , filters = False
    , refreshing = False
    , thumb = ""
    , key = ""
    , typ = ""
    , title = ""
    , agent = ""
    , scanner = ""
    , language = ""
    , uuid = ""
    , updatedAt = 0
    , createdAt = 0
    , scannedAt = 0
    , content = False
    , directory = False
    , contentChangedAt = 0
    , hidden = False
    , location = []
    }


type alias Location =
    { id : Int, path : String }


type alias Media =
    Media.Media


type alias MediaPart =
    Media.MediaPart


type alias Stream =
    Media.Stream


type alias Metadata =
    { ratingKey : String --   A key associated with the item.
    , key : String -- The relative URL of the item information.
    , guid : String --    The unique identifier comprised of the Plex agent and item identifier for the agent.
    , studio : String --  The name of the item studio.
    , typ : String --    The type of media.
    , title : String --   The title of the item.
    , contentRating : String --   The content rating associated with the item.
    , summary : String -- A summary of the item.
    , rating : Float --  The rating for the item.
    , audienceRating : Float --  The audience rating for the item.
    , skipCount : String --   The skip count.
    , year : Int --    The year the item was released.
    , tagline : String -- The tagline associated with the item.
    , thumb : String --   The thumbnail for the item.
    , art : String -- The background artwork used to represent the item.
    , duration : Int --    The length of the item in milliseconds.
    , originallyAvailableAt : String --   The original release date of the item.
    , addedAt : Int -- The date and time the item was added to the library.
    , updatedAt : Int --   The date and time the item was updated in the library.
    , audienceRatingImage : String -- The image associated with the audience rating.
    , chapterSource : String --   The chapter source type.
    , ratingImage : String -- The image associated with the rating.
    , medias : List Media
    , originalTitle : String
    , includedAt : Int
    , index : Int
    , parentKey : String
    , parentRatingKey : String
    , parentTitle : String
    , parentYear : Int
    , parentThumb : String
    , parentTheme : String
    , parentGuid : String
    , parentIndex : Int
    , parentStudio : String
    , grandparentTitle : String
    , grandparentKey : String
    , grandparentRatingKey : String
    , grandparentGuid : String
    , grandparentThumb : String
    , grandparentArt : String
    , grandparentTheme : String
    , grandparentIndex : Int
    , grandparentStudio : String
    , genres : List Genre
    , directors : List Director
    , writers : List Writer
    , roles : List Role
    , ratings : List Rating
    , guids : List Guid
    , countries : List Country
    , primaryExtraKey : String
    , hasPremiumExtras : String
    , hasPremiumPrimaryExtra : String
    , lastViewedAt : Maybe Int
    , viewCount : Maybe Int
    , viewOffset : Maybe Int
    }


initialMetadata : Metadata
initialMetadata =
    { ratingKey = ""
    , key = ""
    , guid = ""
    , studio = ""
    , typ = ""
    , title = ""
    , contentRating = ""
    , summary = ""
    , rating = 0
    , audienceRating = 0
    , skipCount = ""
    , year = 0
    , tagline = ""
    , thumb = ""
    , art = ""
    , duration = 0
    , originallyAvailableAt = ""
    , addedAt = 0
    , updatedAt = 0
    , audienceRatingImage = ""
    , chapterSource = ""
    , ratingImage = ""
    , medias = []
    , originalTitle = ""
    , includedAt = 0
    , index = 0
    , parentKey = ""
    , parentRatingKey = ""
    , parentTitle = ""
    , parentYear = 0
    , parentThumb = ""
    , parentTheme = ""
    , parentGuid = ""
    , parentIndex = 0
    , parentStudio = ""
    , grandparentTitle = ""
    , grandparentKey = ""
    , grandparentRatingKey = ""
    , grandparentGuid = ""
    , grandparentThumb = ""
    , grandparentArt = ""
    , grandparentTheme = ""
    , grandparentIndex = 0
    , grandparentStudio = ""
    , genres = []
    , directors = []
    , writers = []
    , roles = []
    , ratings = []
    , guids = []
    , countries = []
    , primaryExtraKey = ""
    , hasPremiumExtras = ""
    , hasPremiumPrimaryExtra = ""
    , lastViewedAt = Nothing
    , viewCount = Nothing
    , viewOffset = Nothing
    }


metadataDecoder : Decoder Metadata
metadataDecoder =
    let
        decoder =
            Decode.map7
                (\summary guid typ thumb title duration grandparentTitle ->
                    { initialMetadata
                        | summary = summary
                        , guid = guid
                        , typ = typ
                        , thumb = thumb
                        , title = title
                        , duration = duration
                        , grandparentTitle = grandparentTitle
                    }
                )
                (Decode.field "summary" Decode.string)
                (Decode.field "guid" Decode.string)
                (Decode.field "type" Decode.string)
                (Decode.field "thumb" Decode.string)
                (maybeEmptyString <| Decode.field "title" Decode.string)
                (maybeZero <| Decode.field "duration" Decode.int)
                (maybeEmptyString <| Decode.field "grandparentTitle" Decode.string)

        decoder2 =
            Decode.map8
                (\data grandparentTitle grandparentThumb parentTitle parentThumb tagline contentRating originallyAvailableAt ->
                    { data
                        | grandparentTitle = grandparentTitle
                        , grandparentThumb = grandparentThumb
                        , parentTitle = parentTitle
                        , parentThumb = parentThumb
                        , tagline = tagline
                        , contentRating = contentRating
                        , originallyAvailableAt = originallyAvailableAt
                    }
                )
                decoder
                (maybeEmptyString <| Decode.field "grandparentTitle" Decode.string)
                (maybeEmptyString <| Decode.field "grandparentThumb" Decode.string)
                (maybeEmptyString <| Decode.field "parentTitle" Decode.string)
                (maybeEmptyString <| Decode.field "parentThumb" Decode.string)
                (maybeEmptyString <| Decode.field "tagline" Decode.string)
                (maybeEmptyString <| Decode.field "contentRating" Decode.string)
                (maybeEmptyString <| Decode.field "originallyAvailableAt" Decode.string)

        decoder3 =
            Decode.map4
                (\data index parentIndex grandparentIndex ->
                    { data
                        | index = index
                        , parentIndex = parentIndex
                        , grandparentIndex = grandparentIndex
                    }
                )
                decoder2
                (maybeZero <| Decode.field "index" Decode.int)
                (maybeZero <| Decode.field "parentIndex" Decode.int)
                (maybeZero <| Decode.field "grandparentIndex" Decode.int)

        decoder4 =
            Decode.map4
                (\data ratingKey parentRatingKey grandparentRatingKey ->
                    { data
                        | ratingKey = ratingKey
                        , parentRatingKey = parentRatingKey
                        , grandparentRatingKey = grandparentRatingKey
                    }
                )
                decoder3
                (maybeEmptyString <| Decode.field "ratingKey" Decode.string)
                (maybeEmptyString <| Decode.field "parentRatingKey" Decode.string)
                (maybeEmptyString <| Decode.field "grandparentRatingKey" Decode.string)

        decoder5 =
            Decode.map8
                (\data viewOffset lastViewedAt viewCount rating ratingImage audienceRating audienceRatingImage ->
                    { data
                        | viewOffset = viewOffset
                        , lastViewedAt = lastViewedAt
                        , viewCount = viewCount
                        , rating = rating
                        , ratingImage = ratingImage
                        , audienceRating = audienceRating
                        , audienceRatingImage = audienceRatingImage
                    }
                )
                decoder4
                (Decode.maybe <| Decode.field "viewOffset" Decode.int)
                (Decode.maybe <| Decode.field "lastViewedAt" Decode.int)
                (Decode.maybe <| Decode.field "viewCount" Decode.int)
                (maybeFloatZero <| Decode.field "rating" Decode.float)
                (maybeEmptyString <| Decode.field "ratingImage" Decode.string)
                (maybeFloatZero <| Decode.field "audienceRating" Decode.float)
                (maybeEmptyString <| Decode.field "audienceRatingImage" Decode.string)

        decoder6 =
            Decode.map5
                (\data directors roles writers medias ->
                    { data
                        | directors = directors
                        , roles = roles
                        , writers = writers
                        , medias = medias
                    }
                )
                decoder5
                (maybeEmptyList <| Decode.field "Director" <| Decode.list directorDecoder)
                (maybeEmptyList <| Decode.field "Role" <| Decode.list roleDecoder)
                (maybeEmptyList <| Decode.field "Writer" <| Decode.list writerDecoder)
                (maybeEmptyList <| Decode.field "Media" <| Decode.list mediaDecoder)
    in
    decoder6


type alias Director =
    { id : Int
    , tag : String
    , filter : String
    }


directorDecoder : Decoder Director
directorDecoder =
    Decode.map3 Director
        (maybeZero <| Decode.field "id" Decode.int)
        (Decode.field "tag" Decode.string)
        (maybeEmptyString <| Decode.field "filter" Decode.string)


type alias Writer =
    Director


writerDecoder =
    directorDecoder


type alias Genre =
    { id : Int
    , tag : String
    , filter : String
    }


type alias Guid =
    { id : String }


type alias Rating =
    { image : String
    , value : Float
    , typ : String
    }


type alias Role =
    { tag : String
    , filter : String
    , tagKey : String
    , role : String
    , thumb : String
    }


roleDecoder : Decoder Role
roleDecoder =
    Decode.map5 Role
        (Decode.field "tag" Decode.string)
        (maybeEmptyString <| Decode.field "filter" Decode.string)
        (maybeEmptyString <| Decode.field "tagKey" Decode.string)
        (maybeEmptyString <| Decode.field "role" Decode.string)
        (maybeEmptyString <| Decode.field "thumb" Decode.string)


type alias Country =
    { tag : String, filter : String, id : Int }


type alias Account =
    { id : Int --  An integer value representing the unique identifier for the account.
    , key : String -- The relative URL of the account used to get information about the account.
    , name : String --    The name of the account.
    , defaultAudioLanguage : String --    The default audio language used for the account.
    , autoSelectAudio : Bool -- 1 - automatically select the audio for the account. 0 - do not automatically select the audio for the account.
    , defaultSubtitleLanguage : String -- The default language for subtitles.
    , subtitleMode : Int --    An integer value representing the subtitle mode. The values are unknown.
    , thumb : String --   Thumbnail associated with the account.
    }


type alias Setting =
    { id : String --  The unique string value used to identify the preference.
    , label : String --   The label shown in the Plex Web app for the preference.
    , summary : String -- A descriptive summary of the preference.
    , typ : String --    The value type associated with the preference.
    , default : String -- The default value for the preference.
    , value : String --   The current value of the preference.
    , hidden : Bool --  Indicates if the preference is hidden.
    , advanced : Bool --    Indicates the preference is shown when the "Show Advanced" button is clicked in the Plex settings.
    , group : String --   The name of the Plex settings group where the preference can be found.
    , enumValues : List ( String, String ) --  The valid values for the preference in a key/value pair list.
    }


type alias Section =
    { title : String
    , more : Bool
    , data : List Metadata
    , hubIdentifier : String
    }


type alias Client =
    { token : String
    , serverAddress : String
    , serverName : String
    , id : String
    , email : String
    , password : String
    }


httpJsonBodyResolver : Decoder a -> Http.Response String -> Result Http.Error a
httpJsonBodyResolver decoder resp =
    case resp of
        Http.GoodStatus_ m s ->
            Decode.decodeString decoder s
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


clientGetJson : Decoder a -> String -> (Result Http.Error a -> msg) -> Client -> Cmd msg
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


librariesDecoder : Decoder (List Library)
librariesDecoder =
    Decode.at [ "MediaContainer", "Directory" ] <| Decode.list libraryDecoder


libraryDecoder : Decoder Library
libraryDecoder =
    Decode.map8
        (\typ key thumb title language uuid refreshing composite ->
            { initialLibrary
                | typ = typ
                , key = key
                , thumb = thumb
                , title = title
                , language = language
                , uuid = uuid
                , refreshing = refreshing
                , composite = composite
            }
        )
        (maybeEmptyString <| Decode.field "type" Decode.string)
        (maybeEmptyString <| Decode.field "key" Decode.string)
        (maybeEmptyString <| Decode.field "thumb" Decode.string)
        (maybeEmptyString <| Decode.field "title" Decode.string)
        (maybeEmptyString <| Decode.field "language" Decode.string)
        (maybeEmptyString <| Decode.field "uuid" Decode.string)
        (maybeFalse <| Decode.field "refreshing" Decode.bool)
        (maybeEmptyString <| Decode.field "composite" Decode.string)


getLibraries : (Result Http.Error (List Library) -> msg) -> Client -> Cmd msg
getLibraries =
    clientGetJson librariesDecoder "/library/sections"


sectionDecoder : Decoder Section
sectionDecoder =
    Decode.map4
        (\hubIdentifier title more data ->
            { hubIdentifier = hubIdentifier, title = title, more = more, data = data }
        )
        (Decode.field "hubIdentifier" Decode.string)
        (Decode.field "title" Decode.string)
        (maybeFalse <| Decode.field "more" Decode.bool)
        (maybeEmptyList <| Decode.field "Metadata" <| Decode.list metadataDecoder)


sectionsDecoder : Decoder (List Section)
sectionsDecoder =
    Decode.at [ "MediaContainer", "Hub" ] <| Decode.list sectionDecoder


firstSectionDecoder : Decoder Section
firstSectionDecoder =
    Decode.at [ "MediaContainer", "Hub" ] <|
        Decode.index 0 sectionDecoder


metadataListDecoder : Decoder (List Metadata)
metadataListDecoder =
    Decode.field "MediaContainer" <|
        maybeEmptyList <|
            Decode.field "Metadata" <|
                Decode.list metadataDecoder


getSections : (Result Http.Error (List Section) -> msg) -> Client -> Cmd msg
getSections =
    clientGetJson sectionsDecoder "/hubs"


getContinueWatching : (Result Http.Error (List Metadata) -> msg) -> Client -> Cmd msg
getContinueWatching =
    clientGetJson metadataListDecoder "/hubs/home/continueWatching"


getLibraryRecentlyAdded : String -> (Result Http.Error Section -> msg) -> Client -> Cmd msg
getLibraryRecentlyAdded key =
    clientGetJson firstSectionDecoder <| "/hubs/promoted?excludeContinueWatching=1&count=12&contentDirectoryID=" ++ key


getMetadata : String -> Client -> Task Http.Error Metadata
getMetadata key =
    clientGetJsonTask (Decode.at [ "MediaContainer", "Metadata" ] <| Decode.index 0 <| metadataDecoder) ("/library/metadata/" ++ key)


getMetadataChildren : String -> Client -> Task Http.Error (List Metadata)
getMetadataChildren key =
    clientGetJsonTask metadataListDecoder <| "/library/metadata/" ++ key ++ "/children"


getLibrary : String -> (Result Http.Error (List Metadata) -> msg) -> Client -> Cmd msg
getLibrary key =
    clientGetJson metadataListDecoder <| "/library/sections/" ++ key ++ "/all"


firstAccountWithName : Decoder Account -> Decoder Account
firstAccountWithName decoder =
    decoder
        |> Decode.list
        |> Decode.andThen
            (\accs ->
                case List.filter (\acc -> acc.name /= "") accs of
                    [] ->
                        Decode.fail "Account not found"

                    acc :: _ ->
                        Decode.succeed acc
            )
        |> Decode.at [ "MediaContainer", "Account" ]


accountDecoder : Decoder Account
accountDecoder =
    firstAccountWithName <|
        Decode.map8
            (\id key name defaultAudioLanguage autoSelectAudio defaultSubtitleLanguage subtitleMode thumb ->
                { id = id
                , key = key
                , name = name
                , defaultAudioLanguage = defaultAudioLanguage
                , autoSelectAudio = autoSelectAudio
                , defaultSubtitleLanguage = defaultSubtitleLanguage
                , subtitleMode = subtitleMode
                , thumb = thumb
                }
            )
            (Decode.field "id" Decode.int)
            (Decode.field "key" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "defaultAudioLanguage" Decode.string)
            (Decode.field "autoSelectAudio" Decode.bool)
            (Decode.field "defaultSubtitleLanguage" Decode.string)
            (Decode.field "subtitleMode" Decode.int)
            (Decode.field "thumb" Decode.string)


getAccount : (Result Http.Error Account -> msg) -> Client -> Cmd msg
getAccount =
    clientGetJson accountDecoder "/accounts"


type alias TimelineRequest =
    { ratingKey : String
    , time : Int
    , duration : Int
    , state : String
    }


type alias TimelineResponse =
    { playbackState : String, viewOffset : Int, skipCount : Int, viewCount : Int }


timelineResponseDecoder : Decoder TimelineResponse
timelineResponseDecoder =
    Decode.map4 TimelineResponse
        (Decode.field "playbackState" <| Decode.string)
        (Decode.field "viewOffset" <| Decode.int)
        (Decode.field "skipCount" <| Decode.int)
        (Decode.field "viewCount" <| Decode.int)


playerTimeline : TimelineRequest -> (Result Http.Error TimelineResponse -> msg) -> Client -> Cmd msg
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


settingsDecoder : Decoder (List Setting)
settingsDecoder =
    Decode.fail "todo"


getSettings : (Result Http.Error (List Setting) -> msg) -> Client -> Cmd msg
getSettings =
    clientGetJson settingsDecoder "/settings"


transcodedImageUrl : String -> Float -> Float -> Client -> String
transcodedImageUrl thumb width height client =
    clientRequestUrl "/photo/:/transcode" client
        ++ ("&width=" ++ String.fromFloat width)
        ++ ("&height=" ++ String.fromFloat height)
        ++ ("&url=" ++ Url.percentEncode thumb)


initialClient : Client
initialClient =
    { id = ""
    , serverAddress = "https://plex.tv/api/v2"
    , serverName = ""
    , token = ""
    , email = ""
    , password = ""
    }


type alias SignInResponse =
    { username : String
    , thumb : String
    , authToken : String
    }


siginResponseDecoder : Decoder SignInResponse
siginResponseDecoder =
    Decode.map3 SignInResponse
        (Decode.field "username" Decode.string)
        (Decode.field "thumb" Decode.string)
        (Decode.field "authToken" Decode.string)


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


type alias Resource =
    { name : String
    , provides : String
    , accessToken : String
    , connections : List Connection
    }


type alias Connection =
    { local : Bool, uri : String }


resourceDecoder : Decoder Resource
resourceDecoder =
    Decode.map4 Resource
        (Decode.field "name" Decode.string)
        (Decode.field "provides" Decode.string)
        (maybeEmptyString <| Decode.field "accessToken" Decode.string)
        (Decode.field "connections" <| Decode.list connectionDecoder)


connectionDecoder : Decode.Decoder Connection
connectionDecoder =
    Decode.map2 Connection
        (Decode.field "local" Decode.bool)
        (Decode.field "uri" Decode.string)


getResources : Client -> Task Http.Error (List Resource)
getResources =
    clientGetJsonTask (Decode.list resourceDecoder) "/resources"
