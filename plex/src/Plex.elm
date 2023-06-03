module Plex exposing (..)

import AccountScreen exposing (accountScreen, avatar)
import Api
import Browser
import Browser.Navigation as N
import Client exposing (Client, initialClient, loadClient, saveClient)
import Components exposing (favicon)
import Dict exposing (Dict)
import Dto exposing (Account, Library, Metadata, Response)
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
import ReactNative exposing (null, touchableOpacity)
import ReactNative.Alert as Alert
import ReactNative.Animated as Animated
import ReactNative.Dimensions as Dimensions
import ReactNative.Easing as Easing
import ReactNative.Events exposing (onPress)
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (component, componentModel, getId, name, options)
import ReactNative.Settings as Settings
import Set
import SignInModel exposing (SignInMsg)
import SignInScreen exposing (signInScreen, signInUpdate)
import Task exposing (Task)
import Theme
import Time
import Utils
import VideoScreen exposing (videoScreen)


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( Initial key, loadClient (Result.toMaybe >> GotSavedClient) )


hijackUnauthorizedError : (Response a -> Msg) -> (Response a -> Msg)
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


getLibraryDetails : Client -> String -> Cmd Msg
getLibraryDetails client key =
    Api.getLibrary key (hijackUnauthorizedError <| GotLibraryDetail key) client


getLibraryRecentlyAdded : Client -> String -> Cmd Msg
getLibraryRecentlyAdded client key =
    Api.getLibraryRecentlyAdded key
        (hijackUnauthorizedError
            (\section ->
                GotLibraryRecentlyAdded key (Result.map .data section)
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


waitScanningFinish : String -> Client -> Task Http.Error (List Library)
waitScanningFinish key client =
    Process.sleep 2000
        |> Task.andThen
            (\_ ->
                Api.getLibrariesTask client
                    |> Task.andThen
                        (\libs ->
                            if
                                case Utils.findItem (\lib -> lib.key == key) libs of
                                    Just lib ->
                                        lib.scanning

                                    _ ->
                                        False
                            then
                                waitScanningFinish key client

                            else
                                Task.succeed libs
                        )
            )


scanLibrary : String -> Client -> Cmd Msg
scanLibrary key client =
    Api.scanLibrary key client
        |> Task.andThen (\_ -> waitScanningFinish key client)
        |> Task.attempt (hijackUnauthorizedError GotLibraries)


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


getTVShowAndNextEpisode : String -> String -> String -> Client -> Cmd Msg
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
selectSubtitle _ partId subtitleStreamId client =
    Api.selectSubtitle partId subtitleStreamId client
        |> Task.attempt (hijackUnauthorizedError <| always SubtitleChanged)


sendDecision newSession { metadata, sessionId } client =
    Api.sendDecision newSession metadata.ratingKey sessionId (always <| RestartPlaySession True newSession) client


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


updateEpisodes : String -> Response (List Metadata) -> List TVSeason -> List TVSeason
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
                ]
            )

        _ ->
            ( SignIn { client = initialClient, navKey = navKey, submitting = False }
            , Cmd.map SignInMsg <| Random.generate SignInModel.GotClientId Utils.generateIdentifier
            )


signInSubmitResponse client navKey =
    ( Home <| initHomeModel client navKey
    , Cmd.batch
        [ saveClient NoOp client
        , getLibraries client
        , getAccount client
        ]
    )


gotLibraries resp m =
    case resp of
        Ok libs ->
            ( Home { m | libraries = libs }
            , Cmd.batch <|
                getContinueWatching m.client
                    :: List.concatMap
                        (\lib ->
                            [ getLibraryDetails m.client lib.key
                            , getLibraryRecentlyAdded m.client lib.key
                            ]
                        )
                        libs
            )

        Err _ ->
            ( Home
                { m
                    | libraries =
                        List.map (\lib -> { lib | scanning = False })
                            m.libraries
                }
            , Alert.showAlert (always NoOp) "Load libraries failed." []
            )


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
    , saveClient NoOp { client | token = "", serverAddress = "" }
    )


replaceVideo : Client -> Metadata -> VideoPlayer -> ( VideoPlayer, Cmd Msg )
replaceVideo client ({ ratingKey, viewOffset } as metadata) videoPlayer =
    if ratingKey == videoPlayer.metadata.ratingKey then
        ( { videoPlayer | state = Playing, seeking = False, episodesOpen = False }, Cmd.none )

    else
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
            , getStreams ratingKey client
            ]
        )


playVideo : Metadata -> HomeModel -> ( Model, Cmd Msg )
playVideo ({ ratingKey, viewOffset } as metadata) ({ navKey, videoPlayer, client } as m) =
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
                    findNext (\ep -> ep.ratingKey == ratingKey) episodes

                _ ->
                    Nothing

        _ ->
            Nothing


{-| return Err True means not giving up, gonna try to fetch TVShow and then try again
return Err False means TVShow already downloaded and there is no more episode
-}
getNextEpisode : Metadata -> Dict String (Response TVShow) -> Result Bool Metadata
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


videoPlayerControlAction : String -> Client -> Dict String (Response TVShow) -> VideoPlayerControlAction -> VideoPlayer -> ( VideoPlayer, Cmd Msg )
videoPlayerControlAction lang client tvShows action videoPlayer =
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
            , savePlaybackTime videoPlayer client
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

        SetSearchSubtitleOpen open ->
            let
                searchSubtitle =
                    videoPlayer.searchSubtitle
            in
            ( { videoPlayer
                | searchSubtitle = { searchSubtitle | open = open, language = lang }
              }
            , Api.searchSubtitle
                videoPlayer.metadata.ratingKey
                lang
                ""
                (VideoPlayerControl << GotSearchSubtitle)
                client
            )

        SendSearchSubtitle title ->
            let
                searchSubtitle =
                    videoPlayer.searchSubtitle
            in
            ( { videoPlayer | searchSubtitle = { searchSubtitle | items = Nothing, title = title } }
            , Api.searchSubtitle
                videoPlayer.metadata.ratingKey
                lang
                title
                (VideoPlayerControl << GotSearchSubtitle)
                client
            )

        GotSearchSubtitle resp ->
            let
                { searchSubtitle } =
                    videoPlayer
            in
            ( { videoPlayer
                | searchSubtitle =
                    { searchSubtitle | items = Just resp }
              }
            , Cmd.none
            )

        ApplySubtitle subtitleKey ->
            let
                { searchSubtitle } =
                    videoPlayer
            in
            ( { videoPlayer
                | searchSubtitle =
                    { searchSubtitle | downloadings = Set.insert subtitleKey searchSubtitle.downloadings }
              }
            , Api.applySubtitle
                videoPlayer.metadata.ratingKey
                subtitleKey
                (VideoPlayerControl << ApplySubtitleResp subtitleKey)
                client
            )

        ApplySubtitleResp subtitleKey _ ->
            -- TODO: Show error
            let
                { searchSubtitle } =
                    videoPlayer
            in
            ( { videoPlayer
                | searchSubtitle =
                    { searchSubtitle | downloadings = Set.remove subtitleKey searchSubtitle.downloadings }
              }
            , getStreams videoPlayer.metadata.ratingKey client
            )

        ChangeSearchSubtitleLanguage language ->
            let
                { searchSubtitle } =
                    videoPlayer
            in
            ( { videoPlayer | searchSubtitle = { searchSubtitle | language = language } }
            , Api.searchSubtitle
                videoPlayer.metadata.ratingKey
                language
                searchSubtitle.title
                (VideoPlayerControl << GotSearchSubtitle)
                client
            )


extendTimeToHideControls : Cmd Msg
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


insertTVShowIfNotExist : String -> TVShow -> Dict String (Response TVShow) -> Dict String (Response TVShow)
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
                Home ({ videoPlayer, client } as m) ->
                    case resp of
                        Ok ( tvShow, Just nextEpisode ) ->
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
                        , getLibraries client
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
                Home { client, videoPlayer } ->
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
                    ( Home { m | refreshing = True }, getLibraries m.client )

                _ ->
                    ( model, Cmd.none )

        OnVideoEnd ->
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
                Home ({ videoPlayer, client, tvShows, account } as m) ->
                    let
                        lang =
                            case account of
                                Just acc ->
                                    acc.defaultSubtitleLanguage

                                _ ->
                                    "en"

                        ( vp, cmd ) =
                            videoPlayerControlAction lang client tvShows action videoPlayer
                    in
                    ( Home { m | videoPlayer = vp }
                    , Cmd.batch [ extendTimeToHideControls, cmd ]
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

        ScanLibrary key ->
            case model of
                Home ({ client, libraries } as m) ->
                    ( Home
                        { m
                            | libraries =
                                List.map
                                    (\lib ->
                                        if lib.key == key then
                                            { lib | scanning = True }

                                        else
                                            lib
                                    )
                                    libraries
                        }
                    , scanLibrary key client
                    )

                _ ->
                    ( model, Cmd.none )



-- VIEW


accountAvatar : Maybe Account -> Html Msg
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
