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
import Random
import ReactNative exposing (fragment, null, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.ActionSheetIOS as ActionSheetIOS
import ReactNative.Alert as Alert
import ReactNative.Dimensions as Dimensions
import ReactNative.Events exposing (onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Properties exposing (color, component, componentModel, getId, name, options, size, source, style)
import ReactNative.Settings as Settings
import SignInModel exposing (SignInModel, SignInMsg)
import SignInScreen exposing (signInScreen, signInUpdate)
import Task
import Theme
import Time
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


getTVShow : String -> String -> Client -> Cmd Msg
getTVShow id seasonId client =
    Api.getMetadata id client
        |> Task.andThen
            (\show ->
                Api.getMetadataChildren id client
                    |> Task.map (\seasons -> { info = show, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
            )
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow id)


getSeasons : Metadata -> String -> Client -> Cmd Msg
getSeasons tvShowInfo seasonId client =
    Api.getMetadataChildren tvShowInfo.ratingKey client
        |> Task.map (\seasons -> { info = tvShowInfo, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow tvShowInfo.ratingKey)


getEpisodes : String -> String -> Client -> Cmd Msg
getEpisodes showId seasonId client =
    Api.getMetadataChildren seasonId client
        |> Task.attempt (hijackUnauthorizedError <| GotEpisodes showId seasonId)


savePlaybackTime : VideoPlayer -> Client -> Cmd Msg
savePlaybackTime player client =
    Api.playerTimeline
        { ratingKey = player.ratingKey
        , state = "playing"
        , time = player.playbackTime
        , duration = player.duration
        }
        (hijackUnauthorizedError <| always NoOp)
        client


loadClient : Cmd Msg
loadClient =
    Task.map4
        (\id token serverAddress email ->
            { token = token
            , serverAddress = serverAddress
            , id = id
            , email = email
            , password = ""
            }
        )
        (Settings.get "clientId" <| Utils.maybeEmptyString Decode.string)
        (Settings.get "token" Decode.string)
        (Settings.get "serverAddress" Decode.string)
        (Settings.get "email" <| Utils.maybeEmptyString Decode.string)
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
    ( Home { m | tvShows = updateSelectedSeason seasonId showId m.tvShows }
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


playVideo ratingKey viewOffset duration ({ navKey, videoPlayer } as m) =
    ( Home
        { m
            | videoPlayer =
                { videoPlayer
                    | duration = duration
                    , ratingKey = ratingKey
                    , initialPlaybackTime = Maybe.withDefault 0 viewOffset
                }
        }
    , Cmd.batch
        [ Nav.push navKey "video" ()
        , if videoPlayer.screenMetrics == Dimensions.initialDisplayMetrics then
            Task.perform GotScreenMetrics Dimensions.getScreen

          else
            Cmd.none
        , if String.isEmpty videoPlayer.sessionId then
            Random.generate GotPlaySessionId Utils.generateIdentifier

          else
            Cmd.none
        ]
    )


getNextEpisode ratingKey { tvShows } =
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
    case findTVShowByEpisodeRatingKey ratingKey tvShows of
        Just ( show, season, _ ) ->
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

        GotScreenMetrics screenMetrics ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | screenMetrics = screenMetrics } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotPlaySessionId sessionId ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | sessionId = sessionId } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PlayVideo ratingKey viewOffset duration ->
            case model of
                Home m ->
                    playVideo ratingKey viewOffset duration m

                _ ->
                    ( model, Cmd.none )

        PlayVideoError error ->
            ( model
            , Alert.showAlert (always StopPlayVideo) "Unable to play" [ Alert.message error ]
            )

        StopPlayVideo ->
            case model of
                Home m ->
                    ( model
                    , Cmd.batch
                        [ Nav.goBack m.navKey
                        , savePlaybackTime m.videoPlayer m.client
                        , getContinueWatching m.client
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
                    ( Home { m | videoPlayer = { videoPlayer | playbackTime = time } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnLeaveVideoScreen ->
            case model of
                Home ({ client, videoPlayer } as m) ->
                    ( Home { m | videoPlayer = initialVideoPlayer }
                    , Cmd.batch [ getContinueWatching m.client, savePlaybackTime videoPlayer client ]
                    )

                _ ->
                    ( model, Cmd.none )

        SaveVideoPlayback _ ->
            case model of
                Home ({ client, videoPlayer } as m) ->
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
            case model of
                Home ({ videoPlayer } as m) ->
                    case getNextEpisode videoPlayer.ratingKey m of
                        Just nextEpisode ->
                            ( Home
                                { m
                                    | videoPlayer =
                                        { videoPlayer
                                            | initialPlaybackTime = Maybe.withDefault 0 nextEpisode.viewOffset
                                            , ratingKey = nextEpisode.ratingKey
                                        }
                                }
                            , Cmd.none
                            )

                        _ ->
                            ( model
                            , Cmd.batch
                                [ Nav.goBack m.navKey
                                , savePlaybackTime m.videoPlayer m.client
                                , getContinueWatching m.client
                                ]
                            )

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
                null
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
                        { headerTitle = "Home"
                        , headerLeft = \_ -> favicon 20
                        , headerRight = \_ -> lazy accountAvatar m.account
                        , headerTintColor = "white"
                        , headerStyle = { backgroundColor = Theme.backgroundColor }
                        , orientation = "portrait"
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
                        , orientation = "portrait"
                        }
                    , component accountScreen
                    ]
                    []
                , screen
                    [ name "entity"
                    , options
                        { presentation = "modal"
                        , headerShown = False
                        , orientation = "portrait"
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
                Time.every (10 * 1000) SaveVideoPlayback

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
