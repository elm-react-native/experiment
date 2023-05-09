module Plex exposing (..)

import AccountScreen exposing (accountScreen, avatar)
import Api exposing (Client, Library, Metadata, initialClient)
import Browser
import Browser.Navigation as N
import Components exposing (favicon)
import Dict exposing (Dict)
import EntityScreen exposing (entityScreen)
import HomeScreen exposing (homeScreen)
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (..)
import Process
import Random
import ReactNative exposing (fragment, null, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.ActionSheetIOS as ActionSheetIOS
import ReactNative.Alert as Alert
import ReactNative.Animated as Animated
import ReactNative.Dimensions as Dimensions
import ReactNative.Easing as Easing
import ReactNative.Events exposing (onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (color, component, componentModel, getId, name, options, size, source, style)
import ReactNative.Settings as Settings
import SignInModel exposing (SignInModel, SignInMsg)
import SignInScreen exposing (signInScreen, signInUpdate)
import Task exposing (Task)
import Theme
import Time
import Url
import Url.Parser as Parser
import Url.Parser.Query as Query
import Utils
import VideoScreen exposing (videoScreen)


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( Initial key, loadClient )


hijackUnauthorizedError : (Result Http.Error a -> Msg) -> (Result Http.Error a -> Msg)
hijackUnauthorizedError tagger =
    \resp ->
        case resp of
            Err (Http.BadStatus 401) ->
                SignOut

            _ ->
                tagger resp


getAccount : Client -> Cmd Msg
getAccount =
    Api.getAccount (hijackUnauthorizedError GotAccount)


getLibraries : Client -> Cmd Msg
getLibraries =
    Api.getLibraries (hijackUnauthorizedError GotLibraries)


getContinueWatching : Client -> Cmd Msg
getContinueWatching =
    Api.getContinueWatching GotContinueWatching


getLibraryDetails : Client -> Library -> Cmd Msg
getLibraryDetails client lib =
    Api.getLibrary lib.key (hijackUnauthorizedError <| GotLibraryDetail lib.key) client


getLibraryRecentlyAdded : Client -> Library -> Cmd Msg
getLibraryRecentlyAdded client lib =
    Api.getLibraryRecentlyAdded lib.key
        (hijackUnauthorizedError
            (\section ->
                GotLibraryRecentlyAdded lib.key (Result.map .data section)
            )
        )
        client


getTVShowTask id seasonId client =
    Api.getMetadata id client
        |> Task.andThen
            (\show ->
                Api.getMetadataChildren id client
                    |> Task.map (\seasons -> { info = show, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
            )


getTVShowAndEpisodes : String -> String -> Client -> Task Http.Error TVShow
getTVShowAndEpisodes parentRatingKey grandparentRatingKey client =
    getTVShowTask grandparentRatingKey parentRatingKey client
        |> Task.andThen
            (\tvShow ->
                Api.getMetadataChildren parentRatingKey client
                    |> Task.map
                        (\episodes ->
                            { tvShow
                                | seasons =
                                    updateEpisodes parentRatingKey (Ok episodes) tvShow.seasons
                            }
                        )
            )


getTVShowAndNextEpisode ratingKey parentRatingKey grandparentRatingKey client =
    getTVShowAndEpisodes parentRatingKey grandparentRatingKey client
        |> Task.map (\tvShow -> ( tvShow, getNextEpisodeOfTVShow ratingKey parentRatingKey tvShow ))
        |> Task.attempt (hijackUnauthorizedError <| GotNextEpisode grandparentRatingKey)


getTVShow : String -> String -> Client -> Cmd Msg
getTVShow id seasonId client =
    getTVShowTask id seasonId client
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow id)


getStreams : String -> Client -> Cmd Msg
getStreams id client =
    Api.getMetadata id client
        |> Task.attempt (hijackUnauthorizedError <| GotStreams id)


getSeasons : Metadata -> String -> Client -> Cmd Msg
getSeasons tvShowInfo seasonId client =
    Api.getMetadataChildren tvShowInfo.ratingKey client
        |> Task.map (\seasons -> { info = tvShowInfo, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow tvShowInfo.ratingKey)


getEpisodes : String -> String -> Client -> Cmd Msg
getEpisodes showId seasonId client =
    Api.getMetadataChildren seasonId client
        |> Task.attempt (hijackUnauthorizedError <| GotEpisodes showId seasonId)


selectSubtitle : String -> Int -> Int -> Client -> Cmd Msg
selectSubtitle ratingKey partId subtitleStreamId client =
    Api.selectSubtitle partId subtitleStreamId client
        |> Task.attempt (hijackUnauthorizedError <| always SubtitleChanged)



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


sendDecision newSession { metadata, sessionId } client =
    let
        path =
            -- I don't actaully understand why it is called `/decision`
            -- The parameters seems similiar to video uri
            "/video/:/transcode/universal/decision"
                ++ ("?path=%2Flibrary%2Fmetadata%2F" ++ metadata.ratingKey)
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
    Api.clientGetJson (Decode.succeed ()) path (always <| RestartPlaySession True newSession) client


savePlaybackTime : VideoPlayer -> Client -> Cmd Msg
savePlaybackTime videoPlayer client =
    let
        state =
            case videoPlayer.state of
                Playing ->
                    "playing"

                Paused ->
                    "paused"

                Stopped ->
                    "stopped"
    in
    Api.playerTimeline
        { ratingKey = videoPlayer.metadata.ratingKey
        , state = state
        , time = videoPlayer.playbackTime
        , duration = videoPlayer.metadata.duration
        }
        (hijackUnauthorizedError <| always NoOp)
        client


toDecodeError : Task Never x -> Task Decode.Error x
toDecodeError =
    Task.mapError (always <| Decode.Failure "" Encode.null)


loadClient : Cmd Msg
loadClient =
    Task.map5
        (\id token serverAddress serverName email ->
            { token = token
            , serverAddress = serverAddress
            , serverName = serverName
            , id = id
            , email = email
            , password = ""
            , screenMetrics = Dimensions.initialDisplayMetrics
            }
        )
        (Settings.get "clientId" <| Utils.maybeEmptyString Decode.string)
        (Settings.get "token" Decode.string)
        (Settings.get "serverAddress" Decode.string)
        (Settings.get "serverName" Decode.string)
        (Settings.get "email" <| Utils.maybeEmptyString Decode.string)
        |> Task.map2
            (\screenMetrics data -> { data | screenMetrics = screenMetrics })
            (toDecodeError Dimensions.getScreen)
        |> Task.attempt (Result.toMaybe >> GotSavedClient)


saveClient : Client -> Cmd Msg
saveClient client =
    Task.perform (always NoOp) <|
        let
            encode s =
                if String.isEmpty s then
                    Encode.null

                else
                    Encode.string s
        in
        Settings.set
            [ ( "serverAddress", encode client.serverAddress )
            , ( "serverName", encode client.serverName )
            , ( "token", encode client.token )
            , ( "clientId", encode client.id )
            , ( "email", encode client.email )
            ]


updateEpisodes : String -> Result Http.Error (List Metadata) -> List TVSeason -> List TVSeason
updateEpisodes seasonId resp seasons =
    List.map
        (\season ->
            if season.info.ratingKey == seasonId then
                { season | episodes = Just resp }

            else
                season
        )
        seasons


gotSavedClient : Maybe Client -> N.Key -> ( Model, Cmd Msg )
gotSavedClient savedClient navKey =
    case savedClient of
        Just client ->
            ( Home <| initHomeModel client navKey
            , Cmd.batch
                [ getLibraries client
                , getAccount client
                , getContinueWatching client
                ]
            )

        _ ->
            ( SignIn { client = initialClient, navKey = navKey, submitting = False }
            , Cmd.map SignInMsg <| Random.generate SignInModel.GotClientId Utils.generateIdentifier
            )


signInSubmitResponse client navKey =
    ( Home <| initHomeModel client navKey
    , Cmd.batch
        [ saveClient client
        , getLibraries client
        , getAccount client
        , getContinueWatching client
        ]
    )


gotLibraries resp m =
    case resp of
        Ok libs ->
            ( Home { m | libraries = libs }
            , Cmd.batch <|
                List.concatMap
                    (\lib ->
                        [ getLibraryDetails m.client lib
                        , getLibraryRecentlyAdded m.client lib
                        ]
                    )
                    libs
            )

        Err _ ->
            ( Home m, Alert.showAlert (always NoOp) "Load libraries failed." [] )


gotTVShow showId resp m =
    case resp of
        Ok respShow ->
            ( Home { m | tvShows = Dict.insert showId resp m.tvShows }
            , case findSeason respShow.selectedSeason respShow of
                Just season ->
                    case season.episodes of
                        Just (Ok _) ->
                            Cmd.none

                        _ ->
                            getEpisodes showId season.info.ratingKey m.client

                _ ->
                    Cmd.none
            )

        _ ->
            ( Home m, Cmd.none )


gotEpisodes showId seasonId resp m =
    case Dict.get showId m.tvShows of
        Just (Ok show) ->
            let
                seasons =
                    updateEpisodes seasonId resp show.seasons
            in
            ( Home { m | tvShows = Dict.insert showId (Ok { show | seasons = seasons }) m.tvShows }, Cmd.none )

        _ ->
            ( Home m, Cmd.none )


gotoEntity isContinueWatching metadata m =
    let
        getEpisodesIfNotFetched : String -> TVShow -> Cmd Msg
        getEpisodesIfNotFetched seasonId show =
            case findSeason seasonId show of
                Just { info, episodes } ->
                    case episodes of
                        Just (Ok _) ->
                            Cmd.none

                        _ ->
                            getEpisodes show.info.ratingKey info.ratingKey m.client

                _ ->
                    Cmd.none
    in
    ( case metadata.typ of
        "episode" ->
            Home { m | tvShows = updateSelectedSeason metadata.parentRatingKey metadata.grandparentRatingKey m.tvShows }

        "season" ->
            Home { m | tvShows = updateSelectedSeason metadata.ratingKey metadata.parentRatingKey m.tvShows }

        _ ->
            Home m
    , Cmd.batch
        [ Nav.push m.navKey "entity" { isContinueWatching = isContinueWatching, metadata = metadata }
        , case metadata.typ of
            "episode" ->
                case Dict.get metadata.grandparentRatingKey m.tvShows of
                    Just (Ok show) ->
                        getEpisodesIfNotFetched metadata.parentRatingKey show

                    _ ->
                        getTVShow metadata.grandparentRatingKey metadata.parentRatingKey m.client

            "season" ->
                case Dict.get metadata.parentRatingKey m.tvShows of
                    Just (Ok show) ->
                        getEpisodesIfNotFetched metadata.parentRatingKey show

                    _ ->
                        getTVShow metadata.parentRatingKey metadata.ratingKey m.client

            "show" ->
                case Dict.get metadata.ratingKey m.tvShows of
                    Just (Ok show) ->
                        getEpisodesIfNotFetched "" show

                    _ ->
                        getSeasons metadata "" m.client

            _ ->
                Cmd.none
        ]
    )


changeSeason showId seasonId m =
    ( Home <|
        if m.videoPlayer.episodesOpen then
            let
                videoPlayer =
                    m.videoPlayer
            in
            { m | videoPlayer = { videoPlayer | selectedSeasonKey = seasonId } }

        else
            { m | tvShows = updateSelectedSeason seasonId showId m.tvShows }
    , getEpisodes showId seasonId m.client
    )


signOut client navKey =
    ( SignIn
        { client = { client | token = "", serverAddress = initialClient.serverAddress }
        , navKey = navKey
        , submitting = False
        }
    , saveClient { client | token = "", serverAddress = "" }
    )


replaceVideo : Client -> Metadata -> VideoPlayer -> ( VideoPlayer, Cmd Msg )
replaceVideo client ({ ratingKey, viewOffset, typ } as metadata) videoPlayer =
    let
        startTime : Int
        startTime =
            if ratingKey /= videoPlayer.metadata.ratingKey then
                Maybe.withDefault 0 viewOffset

            else
                videoPlayer.playbackTime
    in
    ( { videoPlayer
        | seekTime = startTime
        , playbackTime = startTime
        , subtitleSeekTime = startTime
        , metadata = metadata
        , state = Playing
        , subtitle = []
        , session = ""
        , episodesOpen = False
      }
    , Cmd.batch
        [ Random.generate GotPlaySession Utils.generateIdentifier
        , if ratingKey /= videoPlayer.metadata.ratingKey then
            getStreams ratingKey client

          else
            Cmd.none
        ]
    )


playVideo : Metadata -> HomeModel -> ( Model, Cmd Msg )
playVideo ({ ratingKey, viewOffset, typ } as metadata) ({ navKey, videoPlayer, client } as m) =
    if m.videoPlayer.state /= Stopped then
        let
            ( newVideoPlayer, cmd ) =
                replaceVideo client metadata videoPlayer
        in
        ( Home { m | videoPlayer = newVideoPlayer }, cmd )

    else
        ( Home
            { m
                | videoPlayer =
                    { videoPlayer
                        | seekTime = Maybe.withDefault 0 viewOffset
                        , playbackTime = Maybe.withDefault 0 viewOffset
                        , metadata = metadata
                        , state = Playing
                        , subtitle = []
                    }
            }
        , Cmd.batch
            [ Nav.push navKey "video" ()
            , getStreams ratingKey client
            , Random.generate GotPlaySession Utils.generateIdentifier
            , if String.isEmpty videoPlayer.sessionId then
                Random.generate GotPlaySessionId Utils.generateIdentifier

              else
                Cmd.none
            ]
        )


getNextEpisodeOfTVShow : String -> String -> TVShow -> Maybe Metadata
getNextEpisodeOfTVShow ratingKey parentRatingKey tvShow =
    let
        findNext pred items =
            case items of
                x :: y :: rest ->
                    if pred x then
                        Just y

                    else
                        findNext pred (y :: rest)

                _ ->
                    Nothing
    in
    case findSeason parentRatingKey tvShow of
        Just season ->
            case season.episodes of
                Just (Ok episodes) ->
                    case findNext (\ep -> ep.ratingKey == ratingKey) episodes of
                        Just next ->
                            Just next

                        Nothing ->
                            Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


{-| return Err True means not giving up, gonna try to fetch TVShow and then try again
return Err False means TVShow already downloaded and there is no more episode
-}
getNextEpisode : Metadata -> Dict String (Result Http.Error TVShow) -> Result Bool Metadata
getNextEpisode { ratingKey, parentRatingKey, grandparentRatingKey } tvShows =
    let
        findNext pred items =
            case items of
                x :: y :: rest ->
                    if pred x then
                        Just y

                    else
                        findNext pred (y :: rest)

                _ ->
                    Nothing
    in
    case Dict.get grandparentRatingKey tvShows of
        Just (Ok tvShow) ->
            case getNextEpisodeOfTVShow ratingKey parentRatingKey tvShow of
                Just next ->
                    Ok next

                _ ->
                    Err False

        _ ->
            Err True


videoPlayerControlAction : Client -> Dict String (Result Http.Error TVShow) -> VideoPlayerControlAction -> VideoPlayer -> ( VideoPlayer, Cmd Msg )
videoPlayerControlAction client tvShows action videoPlayer =
    case action of
        SeekAction stage time ->
            ( case stage of
                SeekStart ->
                    { videoPlayer | seeking = True }

                Seeking ->
                    { videoPlayer | playbackTime = time, seeking = True }

                SeekRelease ->
                    { videoPlayer
                        | seekTime = time
                        , playbackTime = time
                        , seeking = False
                        , subtitleSeekTime = time
                    }
            , Cmd.none
            )

        TogglePlay ->
            ( { videoPlayer
                | state =
                    if videoPlayer.state == Playing then
                        Paused

                    else
                        Playing
                , seeking = False
              }
            , Cmd.none
            )

        NextEpisode ->
            case getNextEpisode videoPlayer.metadata tvShows of
                Ok metadata ->
                    replaceVideo client metadata videoPlayer

                Err b ->
                    ( videoPlayer
                    , if b then
                        getTVShowAndNextEpisode
                            videoPlayer.metadata.ratingKey
                            videoPlayer.metadata.parentRatingKey
                            videoPlayer.metadata.grandparentRatingKey
                            client

                      else
                        Cmd.none
                    )

        ChangeScreenLock lockState ->
            ( { videoPlayer | screenLock = lockState }, Cmd.none )

        ChangeResizeMode resizeMode ->
            ( { videoPlayer | resizeMode = resizeMode }, Cmd.none )

        ChangeSpeed speed ->
            ( { videoPlayer | playbackSpeed = speed }, Cmd.none )

        ChangeSubtitle partId subtitleStreamId ->
            ( { videoPlayer
                | selectedSubtitle = subtitleStreamId
                , subtitle = []
              }
            , selectSubtitle videoPlayer.metadata.ratingKey partId subtitleStreamId client
            )

        ExtendTimeout ->
            ( videoPlayer, Cmd.none )

        SetEpisodesOpen open ->
            ( { videoPlayer
                | episodesOpen = open
                , selectedSeasonKey = videoPlayer.metadata.parentRatingKey
              }
            , if open then
                getTVShowAndEpisodes videoPlayer.metadata.parentRatingKey videoPlayer.metadata.grandparentRatingKey client
                    |> Task.attempt (GotTVShow videoPlayer.metadata.grandparentRatingKey)

              else
                Cmd.none
            )


extendTimeToHideControls =
    Task.perform (\now -> UpdateTimeToHideControls <| Time.posixToMillis now + 5000) Time.now


subittleTimeRange : List Dialogue -> ( Int, Int )
subittleTimeRange subtitle =
    ( subtitle |> List.map .start |> List.minimum |> Maybe.withDefault 0
    , subtitle |> List.map .end |> List.maximum |> Maybe.withDefault 0
    )


hideVideoPlayerControlsAnimation : Animated.Value -> Cmd Msg
hideVideoPlayerControlsAnimation animatedValue =
    animatedValue
        |> Animated.timing { toValue = 0, duration = 200, easing = Easing.cubic }
        |> Animated.start
        |> Task.perform (always HideVideoPlayerControlsAnimationFinish)


insertTVShowIfNotExist showId tvShow tvShows =
    if Dict.member showId tvShows then
        tvShows

    else
        Dict.insert showId (Ok tvShow) tvShows


showVideoPlayerControlsAnimation : Animated.Value -> Cmd Msg
showVideoPlayerControlsAnimation animatedValue =
    animatedValue
        |> Animated.timing { toValue = 1, duration = 200, easing = Easing.cubic }
        |> Animated.start
        |> Task.perform (always NoOp)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotSavedClient savedClient ->
            case model of
                Initial navKey ->
                    gotSavedClient savedClient navKey

                _ ->
                    ( model, Cmd.none )

        SignInMsg (SignInModel.SubmitResponse (Ok client)) ->
            case model of
                SignIn { navKey } ->
                    signInSubmitResponse client navKey

                _ ->
                    ( model, Cmd.none )

        SignInMsg signInMsg ->
            case model of
                SignIn m ->
                    let
                        ( signInModel, signInCmd ) =
                            signInUpdate signInMsg m
                    in
                    ( SignIn signInModel, Cmd.map SignInMsg signInCmd )

                _ ->
                    ( model, Cmd.none )

        GotLibraries resp ->
            case model of
                Home m ->
                    gotLibraries resp m

                _ ->
                    ( model, Cmd.none )

        GotTVShow showId resp ->
            case model of
                Home m ->
                    gotTVShow showId resp m

                _ ->
                    ( model, Cmd.none )

        GotNextEpisode showId resp ->
            case model of
                Home ({ tvShows, videoPlayer, client } as m) ->
                    case resp of
                        Ok ( tvShow, Just nextEpisode ) ->
                            let
                                _ =
                                    Debug.log "GotNextEpisode" nextEpisode.viewOffset
                            in
                            ( Home
                                { m
                                    | tvShows = insertTVShowIfNotExist showId tvShow m.tvShows
                                    , videoPlayer =
                                        { videoPlayer
                                            | seekTime = Maybe.withDefault 0 nextEpisode.viewOffset
                                            , metadata = nextEpisode
                                            , subtitle = []
                                        }
                                }
                            , Cmd.none
                            )

                        Ok ( tvShow, Nothing ) ->
                            ( Home { m | tvShows = insertTVShowIfNotExist showId tvShow m.tvShows }
                            , Cmd.batch
                                [ Nav.goBack m.navKey
                                , savePlaybackTime { videoPlayer | state = Stopped } client
                                , getContinueWatching client
                                ]
                            )

                        _ ->
                            ( model
                            , Cmd.batch
                                [ Nav.goBack m.navKey
                                , savePlaybackTime { videoPlayer | state = Stopped } client
                                , getContinueWatching client
                                ]
                            )

                _ ->
                    ( model, Cmd.none )

        GotEpisodes showId seasonId resp ->
            case model of
                Home m ->
                    gotEpisodes showId seasonId resp m

                _ ->
                    ( model, Cmd.none )

        GotoAccount ->
            case model of
                Home m ->
                    ( model, Nav.push m.navKey "account" {} )

                _ ->
                    ( model, Cmd.none )

        GotoEntity isContinueWatching metadata ->
            case model of
                Home m ->
                    gotoEntity isContinueWatching metadata m

                _ ->
                    ( model, Cmd.none )

        ChangeSeason showId seasonId ->
            case model of
                Home m ->
                    changeSeason showId seasonId m

                _ ->
                    ( model, Cmd.none )

        SignOut ->
            case model of
                Home { client, navKey } ->
                    signOut client navKey

                _ ->
                    ( model, Cmd.none )

        GotPlaySession session ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | session = session } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotPlaySessionId sessionId ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | sessionId = sessionId } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PlayVideo metadata ->
            case model of
                Home m ->
                    playVideo metadata m

                _ ->
                    ( model, Cmd.none )

        PlayVideoError error ->
            ( model
            , Alert.showAlert (always StopPlayVideo) "Unable to play" [ Alert.message error ]
            )

        StopPlayVideo ->
            case model of
                Home ({ videoPlayer, client, navKey } as m) ->
                    let
                        vp =
                            { videoPlayer | state = Stopped }
                    in
                    ( Home { m | videoPlayer = vp }
                    , Cmd.batch
                        [ Nav.goBack navKey
                        , savePlaybackTime vp client
                        , getContinueWatching client
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        OnVideoBuffer isBuffering ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | isBuffering = isBuffering } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnVideoProgress time ->
            case model of
                Home ({ videoPlayer } as m) ->
                    if videoPlayer.seeking then
                        ( model, Cmd.none )

                    else
                        ( Home
                            { m
                                | videoPlayer =
                                    { videoPlayer
                                        | playbackTime = time
                                        , subtitleSeekTime =
                                            if videoPlayer.isBuffering then
                                                time

                                            else
                                                videoPlayer.subtitleSeekTime
                                        , isBuffering = False
                                    }
                            }
                        , Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )

        OnLeaveVideoScreen ->
            case model of
                Home ({ client, videoPlayer } as m) ->
                    ( Home
                        { m
                            | videoPlayer =
                                { initialVideoPlayer
                                    | resizeMode = videoPlayer.resizeMode
                                    , sessionId = videoPlayer.sessionId
                                }
                        }
                    , Cmd.batch
                        [ getContinueWatching m.client
                        , getStreams videoPlayer.metadata.ratingKey m.client
                        , savePlaybackTime { videoPlayer | state = Stopped } client
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        SaveVideoPlayback _ ->
            case model of
                Home ({ client, videoPlayer } as m) ->
                    if videoPlayer.state == Stopped then
                        ( model, Cmd.none )

                    else
                        ( model, savePlaybackTime videoPlayer client )

                _ ->
                    ( model, Cmd.none )

        GotAccount resp ->
            case model of
                Home m ->
                    case resp of
                        Ok account ->
                            ( Home { m | account = Just account }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotLibraryDetail key resp ->
            case model of
                Home m ->
                    ( Home { m | librariesDetails = Dict.insert key resp m.librariesDetails, refreshing = False }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotLibraryRecentlyAdded key resp ->
            case model of
                Home m ->
                    ( Home { m | librariesRecentlyAdded = Dict.insert key resp m.librariesRecentlyAdded }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotContinueWatching resp ->
            case model of
                Home m ->
                    ( Home { m | continueWatching = Just resp, refreshing = False }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RefreshHomeScreen ->
            case model of
                Home m ->
                    ( Home { m | refreshing = True }, Cmd.batch [ getLibraries m.client, getContinueWatching m.client ] )

                _ ->
                    ( model, Cmd.none )

        OnVideoEnd ->
            let
                _ =
                    Debug.log "OnVideoEnd" OnVideoEnd
            in
            case model of
                Home ({ videoPlayer, client, tvShows } as m) ->
                    case getNextEpisode videoPlayer.metadata tvShows of
                        Ok nextEpisode ->
                            ( Home
                                { m
                                    | videoPlayer =
                                        { videoPlayer
                                            | seekTime = Maybe.withDefault 0 nextEpisode.viewOffset
                                            , metadata = nextEpisode
                                            , subtitle = []
                                        }
                                }
                            , Cmd.none
                              --, savePlaybackTime { videoPlayer | state = Stopped } client
                            )

                        Err True ->
                            let
                                _ =
                                    Debug.log "getTVShowAndNextEpisode" videoPlayer.metadata.ratingKey
                            in
                            ( model
                            , getTVShowAndNextEpisode
                                videoPlayer.metadata.ratingKey
                                videoPlayer.metadata.parentRatingKey
                                videoPlayer.metadata.grandparentRatingKey
                                client
                            )

                        Err False ->
                            ( model
                            , Cmd.batch
                                [ Nav.goBack m.navKey
                                , savePlaybackTime { videoPlayer | state = Stopped } client
                                , getContinueWatching client
                                ]
                            )

                _ ->
                    ( model, Cmd.none )

        GotStreams _ data ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home <|
                        case data of
                            Ok metadata ->
                                { m
                                    | videoPlayer =
                                        { videoPlayer
                                            | metadata = metadata
                                            , subtitleSeekTime = videoPlayer.playbackTime
                                            , selectedSubtitle =
                                                case getSelectedSubtitleStream metadata of
                                                    Just stream ->
                                                        stream.id

                                                    _ ->
                                                        0
                                        }
                                    , tvShows = updateEpisode metadata m.tvShows
                                }

                            _ ->
                                m
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ToggleVideoPlayerControls ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home
                        { m
                            | videoPlayer =
                                { videoPlayer
                                    | showControls = not videoPlayer.showControls
                                    , hidingControls = videoPlayer.showControls
                                    , timeToHideControls = Nothing
                                }
                        }
                    , if videoPlayer.showControls then
                        hideVideoPlayerControlsAnimation videoPlayer.playerControlsAnimatedValue

                      else
                        Cmd.batch
                            [ extendTimeToHideControls
                            , showVideoPlayerControlsAnimation videoPlayer.playerControlsAnimatedValue
                            ]
                    )

                _ ->
                    ( model, Cmd.none )

        VideoPlayerControl action ->
            case model of
                Home ({ videoPlayer, client, tvShows } as m) ->
                    let
                        ( vp, cmd ) =
                            videoPlayerControlAction client tvShows action videoPlayer
                    in
                    ( Home { m | videoPlayer = vp }
                    , Cmd.batch
                        [ extendTimeToHideControls
                        , cmd
                        , case action of
                            TogglePlay ->
                                savePlaybackTime vp client

                            _ ->
                                Cmd.none
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        UpdateTimeToHideControls now ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | timeToHideControls = Just now } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        HideVideoPlayerControls now ->
            case model of
                Home ({ videoPlayer } as m) ->
                    let
                        ( vp, cmd ) =
                            case videoPlayer.timeToHideControls of
                                Just time ->
                                    if now >= time then
                                        ( { videoPlayer
                                            | showControls = False
                                            , hidingControls = True
                                            , timeToHideControls = Nothing
                                          }
                                        , hideVideoPlayerControlsAnimation videoPlayer.playerControlsAnimatedValue
                                        )

                                    else if time - now > 5000 then
                                        -- this should not happen, just incase there are bugs causing timeToHideControls be wrong value
                                        ( { videoPlayer | timeToHideControls = Just (now + 5000) }, Cmd.none )

                                    else
                                        ( videoPlayer
                                        , (time - now)
                                            |> toFloat
                                            |> Process.sleep
                                            |> Task.perform (\_ -> HideVideoPlayerControls time)
                                        )

                                _ ->
                                    ( videoPlayer, Cmd.none )
                    in
                    ( Home { m | videoPlayer = vp }, cmd )

                _ ->
                    ( model, Cmd.none )

        GotSubtitle dialogues ->
            let
                _ =
                    Debug.log "dialogues" dialogues
            in
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | subtitle = videoPlayer.subtitle ++ dialogues } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        HideVideoPlayerControlsAnimationFinish ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home
                        { m
                            | videoPlayer =
                                { videoPlayer
                                    | hidingControls = False
                                    , screenLock =
                                        case videoPlayer.screenLock of
                                            ConfirmUnlock ->
                                                Locked

                                            lock ->
                                                lock
                                }
                        }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubtitleChanged ->
            ( model, Random.generate (RestartPlaySession False) Utils.generateIdentifier )

        RestartPlaySession madeDecision session ->
            case model of
                Home ({ videoPlayer, client } as m) ->
                    if madeDecision then
                        ( Home
                            { m
                                | videoPlayer =
                                    { videoPlayer
                                        | session = session
                                        , seekTime = videoPlayer.playbackTime
                                    }
                            }
                        , Cmd.none
                        )

                    else
                        ( model, sendDecision session videoPlayer client )

                _ ->
                    ( model, Cmd.none )



-- VIEW


accountAvatar account =
    touchableOpacity
        [ onPress <| Decode.succeed GotoAccount ]
        [ case account of
            Just acc ->
                avatar acc 24

            _ ->
                avatar { name = "", thumb = "" } 24
        ]


root : Model -> Html Msg
root model =
    case model of
        Initial _ ->
            null

        SignIn m ->
            Html.map SignInMsg <| signInScreen m

        Home m ->
            stackNavigator "Main" [ componentModel m ] <|
                [ screen
                    [ name "home"
                    , options
                        { headerTitle = m.client.serverName
                        , headerLeft = \_ -> favicon 20
                        , headerRight = \_ -> lazy accountAvatar m.account
                        , headerTintColor = "white"
                        , headerStyle =
                            { fontFamily = Theme.fontFamily
                            , backgroundColor = Theme.backgroundColor
                            }
                        }
                    , component homeScreen
                    ]
                    []
                , screen
                    [ name "account"
                    , options
                        { headerTitle = ""
                        , headerBackTitle = Maybe.withDefault "" <| Maybe.map .name m.account
                        , headerTintColor = "white"
                        , headerStyle = { backgroundColor = Theme.backgroundColor }
                        }
                    , component accountScreen
                    ]
                    []
                , screen
                    [ name "entity"
                    , options
                        { presentation = "modal"
                        , headerShown = False
                        }
                    , getId
                        (\{ params } ->
                            case params.metadata.typ of
                                "episode" ->
                                    params.metadata.grandparentRatingKey

                                "season" ->
                                    params.metadata.parentRatingKey

                                _ ->
                                    params.metadata.ratingKey
                        )
                    , component entityScreen
                    ]
                    []
                , screen
                    [ name "video"
                    , options
                        { presentation = "fullScreenModal"
                        , headerShown = False
                        , autoHideHomeIndicator = True
                        , orientation = "landscape"
                        }
                    , component videoScreen
                    , Nav.listeners
                        [ Listeners.beforeRemove <| Decode.succeed <| OnLeaveVideoScreen
                        ]
                    ]
                    []
                ]


subs : Model -> Sub Msg
subs model =
    case model of
        Home m ->
            if isVideoUrlReady m.videoPlayer then
                Sub.batch
                    [ Time.every (10 * 1000) SaveVideoPlayback
                    , if m.videoPlayer.showControls && not m.videoPlayer.seeking then
                        Time.every (5 * 1000) (Time.posixToMillis >> HideVideoPlayerControls)

                      else
                        Sub.none
                    ]

            else
                Sub.none

        _ ->
            Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ key -> init key
        , view =
            \model ->
                { title = ""
                , body =
                    [ root model ]
                }
        , update = update
        , subscriptions = subs
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }
