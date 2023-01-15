module Main exposing (..)

import AccountScreen exposing (accountScreen, avatar)
import Api exposing (Client, Library, Metadata, initialClient)
import Browser
import Browser.Navigation as N
import Components exposing (favicon)
import Dict exposing (Dict)
import EntityScreen exposing (entityScreen)
import HomeScreen exposing (homeScreen)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (..)
import Random
import ReactNative exposing (fragment, ionicon, null, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.ActionSheetIOS as ActionSheetIOS
import ReactNative.Alert as Alert
import ReactNative.Dimensions as Dimensions
import ReactNative.Events exposing (onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Properties exposing (color, component, componentModel, getId, name, options, size, source, style)
import ReactNative.Settings as Settings
import SignInScreen exposing (signInScreen)
import Task
import Theme
import Time
import Utils
import VideoScreen exposing (videoScreen)


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( Initial key
    , loadClient
    )


signInSubmit : Client -> Cmd Msg
signInSubmit =
    Api.getAccount SignInSubmitResponse


getSections : Client -> Cmd Msg
getSections =
    Api.getSections GotSections


getLibraries : Client -> Cmd Msg
getLibraries =
    Api.getLibraries GotLibraries


getLibrarySection : Client -> Library -> Cmd Msg
getLibrarySection client lib =
    Api.getLibrary lib.key
        (\data ->
            GotLibrarySection lib.key <|
                { info = lib
                , data = Just data
                }
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
        |> Task.attempt (GotTVShow id)


getSeasons : Metadata -> String -> Client -> Cmd Msg
getSeasons tvShowInfo seasonId client =
    let
        _ =
            Debug.log "getSeasons" tvShowInfo
    in
    Api.getMetadataChildren tvShowInfo.ratingKey client
        |> Task.map (\seasons -> { info = tvShowInfo, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
        |> Task.attempt (GotTVShow tvShowInfo.ratingKey)


getEpisodes : String -> String -> Client -> Cmd Msg
getEpisodes showId seasonId client =
    Api.getMetadataChildren seasonId client
        |> Task.attempt (GotEpisodes showId seasonId)


savePlaybackTime : VideoPlayer -> Client -> Cmd Msg
savePlaybackTime player client =
    Api.playerTimeline
        { ratingKey = player.ratingKey
        , state = "playing"
        , time = player.playbackTime
        , duration = player.duration
        }
        (always NoOp)
        client


loadClient : Cmd Msg
loadClient =
    Task.map3 Client
        (Settings.get "token" Decode.string)
        (Settings.get "serverAddress" Decode.string)
        (Settings.get "clientId" <| Utils.maybeEmptyString Decode.string)
        |> Task.attempt (Result.toMaybe >> GotoSignIn)


saveClient : Client -> Cmd Msg
saveClient client =
    Task.perform (always NoOp) <|
        Settings.set
            [ ( "serverAddress", Encode.string client.serverAddress )
            , ( "token", Encode.string client.token )
            , ( "clientId", Encode.string client.id )
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotoSignIn savedClient ->
            case model of
                Initial key ->
                    case savedClient of
                        Just client ->
                            ( SignIn { client = client, navKey = key, submitting = True }
                            , Cmd.batch
                                [ signInSubmit client
                                , if String.isEmpty client.id then
                                    Random.generate GotClientId Utils.generateIdentifier

                                  else
                                    Cmd.none
                                ]
                            )

                        _ ->
                            ( SignIn { client = initialClient, navKey = key, submitting = False }
                            , Random.generate GotClientId Utils.generateIdentifier
                            )

                _ ->
                    ( model, Cmd.none )

        SignInInputToken token ->
            case model of
                SignIn m ->
                    let
                        client =
                            m.client
                    in
                    ( SignIn { m | client = { client | token = token } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInInputAddress serverAddress ->
            case model of
                SignIn m ->
                    let
                        client =
                            m.client
                    in
                    ( SignIn { m | client = { client | serverAddress = serverAddress } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInSubmit client ->
            case model of
                SignIn m ->
                    ( SignIn { m | client = client, submitting = True }, signInSubmit client )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Ok account) ->
            case model of
                SignIn { client, navKey } ->
                    ( Home
                        { sections = Nothing
                        , account =
                            if String.isEmpty account.thumb then
                                account

                            else
                                { account | thumb = Api.pathToAuthedUrl account.thumb client }
                        , client = client
                        , tvShows = Dict.empty
                        , navKey = navKey
                        , libraries = Dict.empty
                        , videoPlayer = initialVideoPlayer
                        }
                    , Cmd.batch [ saveClient client, getSections client, getLibraries client ]
                    )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Err err) ->
            case model of
                SignIn m ->
                    let
                        errMessage =
                            case err of
                                Http.BadUrl _ ->
                                    "Server address is invalid."

                                Http.BadStatus 401 ->
                                    "Token is invalid or expired."

                                _ ->
                                    "Network error."
                    in
                    ( SignIn { m | submitting = False }, Alert.showAlert (always NoOp) errMessage [] )

                _ ->
                    ( model, Cmd.none )

        ReloadSections ->
            case model of
                Home m ->
                    ( Home { m | sections = Nothing }, getSections m.client )

                _ ->
                    ( model, Cmd.none )

        GotSections resp ->
            ( case model of
                Home m ->
                    Home { m | sections = Just resp }

                _ ->
                    model
            , Cmd.none
            )

        GotLibraries (Ok libs) ->
            case model of
                Home m ->
                    ( Home
                        { m
                            | libraries =
                                libs
                                    |> List.map (\lib -> ( lib.key, { info = lib, data = Nothing } ))
                                    |> Dict.fromList
                        }
                    , Cmd.batch <| List.map (getLibrarySection m.client) libs
                    )

                _ ->
                    ( model, Cmd.none )

        GotLibraries (Err _) ->
            ( model, Task.perform (always NoOp) <| Alert.alert "Fetch libraries failed." [] )

        GotLibrarySection libraryId resp ->
            case model of
                Home m ->
                    ( Home { m | libraries = Dict.insert libraryId resp m.libraries }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotTVShow showId resp ->
            case model of
                Home m ->
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
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotEpisodes showId seasonId resp ->
            case model of
                Home m ->
                    case Dict.get showId m.tvShows of
                        Just (Ok show) ->
                            let
                                seasons =
                                    updateEpisodes seasonId resp show.seasons
                            in
                            ( Home { m | tvShows = Dict.insert showId (Ok { show | seasons = seasons }) m.tvShows }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ShowSection _ ->
            ( model, Cmd.none )

        ShowEntity _ _ ->
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
                    let
                        getEpisodesIfNotFetched : String -> TVShow -> Cmd Msg
                        getEpisodesIfNotFetched seasonId show =
                            let
                                targetSeason =
                                    findSeason seasonId show
                            in
                            case targetSeason of
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
                            model
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

                _ ->
                    ( model, Cmd.none )

        ChangeSeason showId seasonId ->
            case model of
                Home m ->
                    ( Home { m | tvShows = updateSelectedSeason seasonId showId m.tvShows }, getEpisodes showId seasonId m.client )

                _ ->
                    ( model, Cmd.none )

        SignOut ->
            case model of
                Home ({ client } as m) ->
                    ( SignIn { client = m.client, navKey = m.navKey, submitting = False }
                    , saveClient { client | token = "" }
                    )

                _ ->
                    ( model, Cmd.none )

        DismissKeyboard ->
            ( model, Task.perform (always NoOp) Keyboard.dismiss )

        ShowPicker items ->
            ( model
            , ActionSheetIOS.pickAction (( "Cancel", NoOp ) :: items)
                [ ActionSheetIOS.cancelButtonIndex 0
                , ActionSheetIOS.tintColor Theme.themeColor
                ]
                |> Task.perform (Maybe.withDefault NoOp)
            )

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
                Home ({ navKey, videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | duration = duration, ratingKey = ratingKey } }
                    , Cmd.batch
                        [ Nav.push navKey "video" { ratingKey = ratingKey, viewOffset = viewOffset }
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

                _ ->
                    ( model, Cmd.none )

        PlayVideoError error ->
            ( model
            , Alert.showAlert (always StopPlayVideo) "Unable to play" [ Alert.message error ]
            )

        StopPlayVideo ->
            case model of
                Home m ->
                    let
                        _ =
                            Debug.log "goBack" "should go back"
                    in
                    ( model
                    , Cmd.batch
                        [ Nav.goBack m.navKey
                        , savePlaybackTime m.videoPlayer m.client
                        , getSections m.client
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        GotClientId id ->
            case model of
                SignIn ({ client } as m) ->
                    ( SignIn <| { m | client = { client | id = id } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnVideoPlaybackStateChanged isPlaying ->
            let
                _ =
                    Debug.log "isPlaying" isPlaying
            in
            ( model, Cmd.none )

        OnVideoBuffer isBuffering ->
            let
                _ =
                    Debug.log "isBuffering" isBuffering
            in
            ( model, Cmd.none )

        OnVideoProgress time ->
            case model of
                Home ({ videoPlayer } as m) ->
                    ( Home { m | videoPlayer = { videoPlayer | playbackTime = time } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnVideoEnd ->
            case model of
                Home ({ client, videoPlayer } as m) ->
                    ( Home { m | videoPlayer = initialVideoPlayer }, Cmd.batch [ getSections m.client, savePlaybackTime videoPlayer client ] )

                _ ->
                    ( model, Cmd.none )

        SaveVideoPlayback _ ->
            case model of
                Home ({ client, videoPlayer } as m) ->
                    ( model, savePlaybackTime videoPlayer client )

                _ ->
                    ( model, Cmd.none )



-- VIEW


root : Model -> Html Msg
root model =
    case model of
        Initial _ ->
            null

        SignIn m ->
            signInScreen m

        Home m ->
            fragment []
                [ stackNavigator "Main" [ componentModel m ] <|
                    [ screen
                        [ name "home"
                        , options
                            { headerTitle = "Home"
                            , headerLeft = \_ -> favicon 20
                            , headerRight =
                                \_ ->
                                    touchableOpacity
                                        [ onPress <| Decode.succeed GotoAccount ]
                                        [ avatar m.account 24 ]
                            , headerTintColor = "white"
                            , headerStyle = { backgroundColor = Theme.backgroundColor }
                            }
                        , component homeScreen
                        ]
                        []
                    , screen
                        [ name "account"
                        , options
                            { headerTitle = ""
                            , headerBackTitle = m.account.name
                            , headerTintColor = "white"
                            , headerStyle = { backgroundColor = Theme.backgroundColor }
                            }
                        , component accountScreen
                        ]
                        []
                    , screen
                        [ name "entity"
                        , options
                            { presentation = "formSheet"
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
                            }
                        , component videoScreen
                        , Nav.listeners [ Listeners.blur <| Decode.succeed <| OnVideoEnd ]
                        ]
                        []
                    ]
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
