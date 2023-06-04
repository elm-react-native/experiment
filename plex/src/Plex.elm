module Plex exposing (..)

import AccountScreen exposing (accountScreen, avatar)
import Api
import Browser
import Browser.Navigation as N
import Client exposing (Client, initialClient, loadClient, saveClient)
import Cmds exposing (..)
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
import ReactNative.Dimensions as Dimensions
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


gotSavedClient : Maybe Client -> N.Key -> ( Model, Cmd Msg )
gotSavedClient savedClient navKey =
    case savedClient of
        Just client ->
            ( Home <| initHomeModel client navKey
            , Cmd.batch
                [ Cmd.map HomeMsg <| getLibraries client
                , Cmd.map HomeMsg <| getAccount client
                ]
            )

        _ ->
            ( SignIn { client = initialClient, navKey = navKey, submitting = False }
            , Cmd.map SignInMsg <| Random.generate SignInModel.GotClientId Utils.generateIdentifier
            )


signInSubmitResponse client navKey =
    ( initHomeModel client navKey
    , Cmd.batch
        [ saveClient HomeNoOp client
        , getLibraries client
        , getAccount client
        ]
    )


gotLibraries resp m =
    case resp of
        Ok libs ->
            ( { m | libraries = libs }
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
            ( { m
                | libraries =
                    List.map (\lib -> { lib | scanning = False })
                        m.libraries
              }
            , Alert.showAlert (always HomeNoOp) "Load libraries failed." []
            )


gotTVShow showId resp m =
    case resp of
        Ok respShow ->
            ( { m | tvShows = Dict.insert showId resp m.tvShows }
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
            ( m, Cmd.none )


gotEpisodes showId seasonId resp m =
    case Dict.get showId m.tvShows of
        Just (Ok show) ->
            let
                seasons =
                    updateEpisodes seasonId resp show.seasons
            in
            ( { m | tvShows = Dict.insert showId (Ok { show | seasons = seasons }) m.tvShows }, Cmd.none )

        _ ->
            ( m, Cmd.none )


gotoEntity isContinueWatching metadata m =
    let
        getEpisodesIfNotFetched : String -> TVShow -> Cmd HomeMsg
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
            { m | tvShows = updateSelectedSeason metadata.parentRatingKey metadata.grandparentRatingKey m.tvShows }

        "season" ->
            { m | tvShows = updateSelectedSeason metadata.ratingKey metadata.parentRatingKey m.tvShows }

        _ ->
            m
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
    ( if m.videoPlayer.episodesOpen then
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


replaceVideo : Client -> Metadata -> VideoPlayer -> ( VideoPlayer, Cmd HomeMsg )
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


playVideo : Metadata -> HomeModel -> ( HomeModel, Cmd HomeMsg )
playVideo ({ ratingKey, viewOffset } as metadata) ({ navKey, videoPlayer, client } as m) =
    if m.videoPlayer.state /= Stopped then
        let
            ( newVideoPlayer, cmd ) =
                replaceVideo client metadata videoPlayer
        in
        ( { m | videoPlayer = newVideoPlayer }, cmd )

    else
        ( { m
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


videoPlayerControlAction : String -> Client -> Dict String (Response TVShow) -> VideoPlayerControlAction -> VideoPlayer -> ( VideoPlayer, Cmd HomeMsg )
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
                    { searchSubtitle
                        | items =
                            Just <|
                                Result.map
                                    (List.map
                                        (\stream ->
                                            { stream = stream
                                            , status = Searched
                                            }
                                        )
                                    )
                                    resp
                    }
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
                    setExternalSubtitleStatus subtitleKey Downloading videoPlayer.searchSubtitle
              }
            , Api.applySubtitle
                videoPlayer.metadata.ratingKey
                subtitleKey
                (VideoPlayerControl << ApplySubtitleResp subtitleKey)
                client
            )

        ApplySubtitleResp subtitleKey resp ->
            -- TODO: Show error
            let
                { searchSubtitle } =
                    videoPlayer
            in
            case resp of
                Ok _ ->
                    ( { videoPlayer
                        | searchSubtitle =
                            setExternalSubtitleStatus subtitleKey Downloaded videoPlayer.searchSubtitle
                      }
                    , getStreams videoPlayer.metadata.ratingKey client
                    )

                _ ->
                    ( { videoPlayer
                        | searchSubtitle =
                            setExternalSubtitleStatus subtitleKey Searched videoPlayer.searchSubtitle
                      }
                    , Alert.showAlert (always HomeNoOp) "Plex" [ Alert.message "Download subtitle failed." ]
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


insertTVShowIfNotExist : String -> TVShow -> Dict String (Response TVShow) -> Dict String (Response TVShow)
insertTVShowIfNotExist showId tvShow tvShows =
    if Dict.member showId tvShows then
        tvShows

    else
        Dict.insert showId (Ok tvShow) tvShows


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
                    let
                        ( homeModel, cmd ) =
                            signInSubmitResponse client navKey
                    in
                    ( Home homeModel, Cmd.map HomeMsg cmd )

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

        HomeMsg SignOut ->
            case model of
                Home { client, navKey } ->
                    signOut client navKey

                _ ->
                    ( model, Cmd.none )

        HomeMsg homeMsg ->
            case model of
                Home m ->
                    let
                        ( homeModel, homeCmd ) =
                            homeUpdate homeMsg m
                    in
                    ( Home homeModel, Cmd.map HomeMsg homeCmd )

                _ ->
                    ( model, Cmd.none )


homeUpdate : HomeMsg -> HomeModel -> ( HomeModel, Cmd HomeMsg )
homeUpdate msg model =
    case msg of
        HomeNoOp ->
            ( model, Cmd.none )

        SignOut ->
            ( model, Cmd.none )

        GotLibraries resp ->
            gotLibraries resp model

        GotTVShow showId resp ->
            gotTVShow showId resp model

        GotNextEpisode showId resp ->
            case model of
                { videoPlayer, client } as m ->
                    case resp of
                        Ok ( tvShow, Just nextEpisode ) ->
                            ( { m
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
                            ( { m | tvShows = insertTVShowIfNotExist showId tvShow m.tvShows }
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

        GotEpisodes showId seasonId resp ->
            gotEpisodes showId seasonId resp model

        GotoAccount ->
            ( model, Nav.push model.navKey "account" {} )

        GotoEntity isContinueWatching metadata ->
            gotoEntity isContinueWatching metadata model

        ChangeSeason showId seasonId ->
            changeSeason showId seasonId model

        GotPlaySession session ->
            let
                { videoPlayer } =
                    model
            in
            ( { model | videoPlayer = { videoPlayer | session = session } }, Cmd.none )

        GotPlaySessionId sessionId ->
            let
                { videoPlayer } =
                    model
            in
            ( { model | videoPlayer = { videoPlayer | sessionId = sessionId } }, Cmd.none )

        PlayVideo metadata ->
            playVideo metadata model

        PlayVideoError error ->
            ( model
            , Alert.showAlert (always StopPlayVideo) "Unable to play" [ Alert.message error ]
            )

        StopPlayVideo ->
            let
                { videoPlayer, client, navKey } =
                    model

                vp =
                    { videoPlayer | state = Stopped }
            in
            ( { model | videoPlayer = vp }
            , Cmd.batch
                [ Nav.goBack navKey
                , savePlaybackTime vp client
                , getLibraries client
                ]
            )

        OnVideoBuffer isBuffering ->
            let
                { videoPlayer } =
                    model
            in
            ( { model | videoPlayer = { videoPlayer | isBuffering = isBuffering } }, Cmd.none )

        OnVideoProgress time ->
            let
                { videoPlayer } =
                    model
            in
            if videoPlayer.seeking then
                ( model, Cmd.none )

            else
                ( { model
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

        OnLeaveVideoScreen ->
            let
                { client, videoPlayer } =
                    model
            in
            ( { model
                | videoPlayer =
                    { initialVideoPlayer
                        | resizeMode = videoPlayer.resizeMode
                        , sessionId = videoPlayer.sessionId
                    }
              }
            , Cmd.batch
                [ getContinueWatching model.client
                , getStreams videoPlayer.metadata.ratingKey model.client
                , savePlaybackTime { videoPlayer | state = Stopped } client
                ]
            )

        SaveVideoPlayback _ ->
            let
                { client, videoPlayer } =
                    model
            in
            if videoPlayer.state == Stopped then
                ( model, Cmd.none )

            else
                ( model, savePlaybackTime videoPlayer client )

        GotAccount resp ->
            case resp of
                Ok account ->
                    ( { model | account = Just account }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotLibraryDetail key resp ->
            ( { model | librariesDetails = Dict.insert key resp model.librariesDetails, refreshing = False }, Cmd.none )

        GotLibraryRecentlyAdded key resp ->
            ( { model | librariesRecentlyAdded = Dict.insert key resp model.librariesRecentlyAdded }, Cmd.none )

        GotContinueWatching resp ->
            ( { model | continueWatching = Just resp, refreshing = False }, Cmd.none )

        RefreshHomeScreen ->
            ( { model | refreshing = True }, getLibraries model.client )

        OnVideoEnd ->
            let
                { videoPlayer, client, tvShows } =
                    model
            in
            case getNextEpisode videoPlayer.metadata tvShows of
                Ok nextEpisode ->
                    ( { model
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
                        [ Nav.goBack model.navKey
                        , savePlaybackTime { videoPlayer | state = Stopped } client
                        , getContinueWatching client
                        ]
                    )

        GotStreams _ data ->
            let
                { videoPlayer } =
                    model
            in
            ( case data of
                Ok metadata ->
                    { model
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
                        , tvShows = updateEpisode metadata model.tvShows
                    }

                _ ->
                    model
            , Cmd.none
            )

        ToggleVideoPlayerControls ->
            let
                { videoPlayer } =
                    model
            in
            ( { model
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

        VideoPlayerControl action ->
            let
                { videoPlayer, client, tvShows, account } =
                    model

                lang =
                    case account of
                        Just acc ->
                            acc.defaultSubtitleLanguage

                        _ ->
                            "en"

                ( vp, cmd ) =
                    videoPlayerControlAction lang client tvShows action videoPlayer
            in
            ( { model | videoPlayer = vp }
            , Cmd.batch [ extendTimeToHideControls, cmd ]
            )

        UpdateTimeToHideControls now ->
            let
                { videoPlayer } =
                    model
            in
            ( { model | videoPlayer = { videoPlayer | timeToHideControls = Just now } }, Cmd.none )

        HideVideoPlayerControls now ->
            let
                { videoPlayer } =
                    model

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
            ( { model | videoPlayer = vp }, cmd )

        GotSubtitle dialogues ->
            let
                { videoPlayer } =
                    model
            in
            ( { model | videoPlayer = { videoPlayer | subtitle = videoPlayer.subtitle ++ dialogues } }, Cmd.none )

        HideVideoPlayerControlsAnimationFinish ->
            let
                { videoPlayer } =
                    model
            in
            ( { model
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

        SubtitleChanged ->
            ( model, Random.generate (RestartPlaySession False) Utils.generateIdentifier )

        RestartPlaySession madeDecision session ->
            let
                { videoPlayer, client } =
                    model
            in
            if madeDecision then
                ( { model
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

        ScanLibrary key ->
            let
                { client, libraries } =
                    model
            in
            ( { model
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



-- VIEW


accountAvatar : Maybe Account -> Html HomeMsg
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
            Html.map HomeMsg <|
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
        Home { videoPlayer } ->
            if isVideoUrlReady videoPlayer then
                Sub.batch
                    [ Time.every (10 * 1000) (HomeMsg << SaveVideoPlayback)
                    , if videoPlayer.showControls && not videoPlayer.seeking then
                        Time.every (5 * 1000) (Time.posixToMillis >> (HomeMsg << HideVideoPlayerControls))

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
