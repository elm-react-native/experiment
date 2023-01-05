module Plex exposing (..)

import Api exposing (Account, Client, Library, Metadata, Section, Tree(..))
import Browser
import Browser.Navigation as N
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative
    exposing
        ( activityIndicator
        , button
        , fragment
        , image
        , keyboardAvoidingView
        , null
        , pressable
        , require
        , safeAreaView
        , scrollView
        , sectionList
        , statusBar
        , str
        , text
        , textInput
        , touchableOpacity
        , touchableWithoutFeedback
        , view
        )
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onChangeText, onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Platform as Platform
import ReactNative.Properties
    exposing
        ( barStyle
        , behavior
        , color
        , component
        , componentModel
        , contentContainerStyle
        , disabled
        , horizontal
        , name
        , options
        , persistentScrollbar
        , placeholder
        , placeholderTextColor
        , secureTextEntry
        , showsHorizontalScrollIndicator
        , source
        , stringValue
        , style
        , title
        )
import ReactNative.Settings as Settings
import ReactNative.StyleSheet as StyleSheet
import Task exposing (Task)



-- MODEL


type alias SignInModel =
    { client : Client, navKey : N.Key, submitting : Bool }


type alias RemoteData data =
    Maybe (Result Http.Error data)


type alias HomeModel =
    { continueWatching : RemoteData Section
    , recentlyAdded : RemoteData Section
    , libraries : List (RemoteData Section)
    , client : Client
    , account : Account
    , navKey : N.Key
    }


type Model
    = Initial N.Key
    | SignIn SignInModel
    | Home HomeModel


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( Initial key
    , Task.map2 (\token serverAddress -> { token = token, serverAddress = serverAddress })
        (Settings.get "token" Decode.string)
        (Settings.get "serverAddress" Decode.string)
        |> Task.attempt (Result.map SignInSubmit >> Result.withDefault GotoSignIn)
    )



-- UPDATE


type Msg
    = NoOp
    | GotoSignIn
    | SignInInputAddress String
    | SignInInputToken String
    | SignInSubmit Client
    | SignInSubmitResponse (Result Http.Error Account)
    | GotContinueWatching (Result Http.Error Section)
    | GotRecentlyAdded (Result Http.Error Section)
    | DismissKeyboard
    | ShowSection String
    | ShowEntity String String


initialClient =
    { serverAddress = "", token = "" }


signInSubmit =
    Api.getAccount SignInSubmitResponse


getContinueWatching =
    Api.getContinueWatching GotContinueWatching


saveClient client =
    Task.perform (always NoOp) <|
        Settings.set
            [ ( "serverAddress", Encode.string client.serverAddress )
            , ( "token", Encode.string client.token )
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotoSignIn ->
            case model of
                Initial key ->
                    ( SignIn { client = initialClient, navKey = key, submitting = False }, Cmd.none )

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
                Initial key ->
                    ( SignIn { client = client, navKey = key, submitting = True }, signInSubmit client )

                SignIn m ->
                    ( SignIn { m | client = client, submitting = True }, signInSubmit client )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Ok account) ->
            case model of
                SignIn { client, navKey } ->
                    ( Home
                        { continueWatching = Nothing
                        , recentlyAdded = Nothing
                        , libraries = []
                        , account = account
                        , client = client
                        , navKey = navKey
                        }
                    , Cmd.batch [ saveClient client, getContinueWatching client ]
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

                                e ->
                                    "Network error."
                    in
                    ( SignIn { m | submitting = False }, Task.perform (always NoOp) <| Alert.alert errMessage [] )

                _ ->
                    ( model, Cmd.none )

        GotContinueWatching resp ->
            ( case model of
                Home m ->
                    Home { m | continueWatching = Just resp }

                _ ->
                    model
            , Cmd.none
            )

        GotRecentlyAdded resp ->
            ( case model of
                Home m ->
                    Home { m | recentlyAdded = Just resp }

                _ ->
                    model
            , Cmd.none
            )

        ShowSection sectionId ->
            ( model, Cmd.none )

        ShowEntity sectionId entityId ->
            ( model, Cmd.none )

        DismissKeyboard ->
            ( model, Task.perform (always NoOp) Keyboard.dismiss )



-- VIEW


themeColor =
    "#EBAF00"


signInStyles =
    StyleSheet.create
        { container =
            { justifyContent = "center"
            , alignItems = "center"
            , display = "flex"
            , height = "100%"
            , width = "100%"
            , backgroundColor = "#2c2c2c"
            }
        , form =
            { width = "80%" }
        , logo =
            { height = 59
            , width = 128
            , alignSelf = "center"
            , marginBottom = 30
            }
        , input =
            { borderBottomWidth = StyleSheet.hairlineWidth
            , height = 44
            , marginBottom = 20
            , color = "white"
            , borderColor = themeColor
            }
        , button =
            { backgroundColor = themeColor
            , height = 44
            , borderRadius = 3
            , justifyContent = "center"
            , alignItems = "center"
            }
        , buttonDisabled =
            { opacity = 0.5 }
        , buttonText =
            { color = "white", fontSize = 16, fontWeight = "bold" }
        }


signInScreen : SignInModel -> Html Msg
signInScreen { client, navKey, submitting } =
    touchableWithoutFeedback
        [ onPress <| Decode.succeed DismissKeyboard
        ]
        [ view
            [ style signInStyles.container
            ]
            [ keyboardAvoidingView
                [ style signInStyles.form
                , behavior "height"
                ]
                [ image
                    [ source <| require "./assets/plex-logo.png"
                    , style signInStyles.logo
                    ]
                    []
                , textInput
                    [ style signInStyles.input
                    , disabled submitting
                    , placeholder "Address http://192.168.1.1:32400"
                    , placeholderTextColor "#555"
                    , stringValue client.serverAddress
                    , onChangeText SignInInputAddress
                    ]
                    []
                , textInput
                    [ style signInStyles.input
                    , disabled submitting
                    , placeholder "Token hoSG7jeEsYDMQnstqnzP"
                    , placeholderTextColor "#555"
                    , stringValue client.token
                    , secureTextEntry True
                    , onChangeText SignInInputToken
                    ]
                    []
                , let
                    buttonDisabled =
                        submitting
                            || (client.serverAddress == "")
                            || (client.token == "")
                  in
                  touchableOpacity
                    [ if buttonDisabled then
                        style <| StyleSheet.compose signInStyles.button signInStyles.buttonDisabled

                      else
                        style signInStyles.button
                    , disabled buttonDisabled
                    , onPress <| Decode.succeed <| SignInSubmit client
                    ]
                    [ if submitting then
                        activityIndicator [ color "white" ] []

                      else
                        text
                            [ style signInStyles.buttonText ]
                            [ str "Sign In" ]
                    ]
                ]
            ]
        ]


homeStyles =
    StyleSheet.create
        { sectionTitle =
            { fontSize = 12
            , fontWeight = "bold"
            }
        , sectionContent =
            { flexDirection = "row"
            , justifyContent = "space-around"
            }
        , image =
            { borderRadius = 5
            , margin = 5
            }
        }


itemView : Client -> Tree Metadata -> Html Msg
itemView client item =
    let
        metadata =
            case item of
                Branch meta _ ->
                    meta

                Leaf meta ->
                    meta

        _ =
            Debug.log "item" <| metadata.thumb
    in
    view []
        [ image
            [ source
                { uri = client.serverAddress ++ metadata.thumb ++ "?X-Plex-Token=" ++ client.token
                , width = 110
                , height = 150
                }
            , style homeStyles.image
            ]
            []

        --, text [] [ str metadata.title ]
        ]


sectionView : Client -> RemoteData Section -> Html Msg
sectionView client data =
    case data of
        Just (Ok section) ->
            view [ style homeStyles.sectionTitle ]
                [ str section.title
                , scrollView
                    [ contentContainerStyle homeStyles.sectionContent
                    , showsHorizontalScrollIndicator False
                    , horizontal True
                    ]
                    (List.map (itemView client) section.data)
                ]

        Just (Err _) ->
            text [] [ str "Load Error" ]

        _ ->
            activityIndicator [] []


homeScreen model _ =
    safeAreaView []
        [ scrollView
            [ persistentScrollbar False
            ]
            (List.map (sectionView model.client) <| [ model.continueWatching, model.recentlyAdded ] ++ model.libraries)
        ]


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
                    , options { title = "Home" }
                    , component homeScreen
                    ]
                    []
                ]


subs _ =
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
