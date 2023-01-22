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
import SignInScreen exposing (signInScreen)
import Task
import Theme
import Time
import Utils
import VideoScreen exposing (videoScreen)


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( Initial key, loadClient )


findLocalServer : List Api.Resource -> Maybe { serverAddress : String, token : String }
findLocalServer resources =
    resources
        |> List.filterMap
            (\resource ->
                if resource.provides == "server" then
                    case List.head <| List.filter (\conn -> conn.local) resource.connections of
                        Just conn ->
                            Just { serverAddress = conn.uri, token = resource.accessToken }

                        _ ->
                            Nothing

                else
                    Nothing
            )
        |> List.head


hijackUnauthorizedError : (Result Http.Error a -> Msg) -> (Result Http.Error a -> Msg)
hijackUnauthorizedError tagger =
    \resp ->
        case resp of
            Err (Http.BadStatus 401) ->
                SignOut

            _ ->
                tagger resp


signInSubmit : Client -> Cmd Msg
signInSubmit client =
    Api.signIn client
        |> Task.andThen (\{ authToken } -> Api.getResources { client | token = authToken })
        |> Task.andThen
            (\resources ->
                case findLocalServer resources of
                    Just { token, serverAddress } ->
                        Task.succeed
                            { client
                                | token = token
                                , serverAddress = serverAddress
                                , password = ""
                            }

                    _ ->
                        Task.fail <| Http.BadBody "Can't find local server. This App only support local server."
            )
        |> Task.attempt SignInSubmitResponse


getAccount : Client -> Cmd Msg
getAccount =
    Api.getAccount (hijackUnauthorizedError GotAccount)


getSections : Client -> Cmd Msg
getSections =
    Api.getSections (hijackUnauthorizedError GotSections)


getLibraries : Client -> Cmd Msg
getLibraries =
    Api.getLibraries (hijackUnauthorizedError GotLibraries)


getLibrarySection : Client -> Library -> Cmd Msg
getLibrarySection client lib =
    Api.getLibrary lib.key
        (hijackUnauthorizedError <|
            \data ->
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
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow id)


getSeasons : Metadata -> String -> Client -> Cmd Msg
getSeasons tvShowInfo seasonId client =
    let
        _ =
            Debug.log "getSeasons" tvShowInfo
    in
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotSavedClient savedClient ->
            case model of
                Initial navKey ->
                    case savedClient of
                        Just client ->
                            ( Home <| initHomeModel client navKey, Cmd.batch [ getSections client, getLibraries client, getAccount client ] )

                        _ ->
                            ( SignIn { client = initialClient, navKey = navKey, submitting = False }
                            , Random.generate GotClientId Utils.generateIdentifier
                            )

                _ ->
                    ( model, Cmd.none )

        SignInInputEmail email ->
            case model of
                SignIn m ->
                    let
                        client =
                            m.client
                    in
                    ( SignIn { m | client = { client | email = email } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInInputPassword password ->
            case model of
                SignIn m ->
                    let
                        client =
                            m.client
                    in
                    ( SignIn { m | client = { client | password = password } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInSubmit ->
            case model of
                SignIn m ->
                    ( SignIn { m | submitting = True }, signInSubmit m.client )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Ok client) ->
            case model of
                SignIn { navKey } ->
                    ( Home <| initHomeModel client navKey
                    , Cmd.batch [ saveClient client, getSections client, getLibraries client, getAccount client ]
                    )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Err err) ->
            case model of
                SignIn m ->
                    let
                        errMessage =
                            case err of
                                Http.BadStatus 401 ->
                                    "Email or password is wrong."

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
                    let
                        _ =
                            Debug.log "ChangeSeason" seasonId
                    in
                    ( Home { m | tvShows = updateSelectedSeason seasonId showId m.tvShows }
                    , getEpisodes showId seasonId m.client
                    )

                _ ->
                    ( model, Cmd.none )

        SignOut ->
            case model of
                Home { client, navKey } ->
                    ( SignIn
                        { client = { client | token = "", serverAddress = initialClient.serverAddress }
                        , navKey = navKey
                        , submitting = False
                        }
                    , saveClient { client | token = "", serverAddress = "" }
                    )

                _ ->
                    ( model, Cmd.none )

        DismissKeyboard ->
            ( model, Task.perform (always NoOp) Keyboard.dismiss )

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
                    , Cmd.batch [ getSections m.client, savePlaybackTime videoPlayer client ]
                    )

                _ ->
                    ( model, Cmd.none )

        SaveVideoPlayback _ ->
            case model of
                Home ({ client, videoPlayer } as m) ->
                    ( model, savePlaybackTime videoPlayer client )

                _ ->
                    ( model, Cmd.none )

        GotAccount (Ok account) ->
            case model of
                Home m ->
                    ( Home { m | account = Just account }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotAccount (Err _) ->
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
            stackNavigator "Main" [ componentModel m ] <|
                [ screen
                    [ name "home"
                    , options
                        { headerTitle = "Home"
                        , headerLeft = \_ -> favicon 20
                        , headerRight =
                            \_ ->
                                touchableOpacity
                                    [ onPress <| Decode.succeed GotoAccount ]
                                    [ case m.account of
                                        Just account ->
                                            avatar account 24

                                        _ ->
                                            null
                                    ]
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
