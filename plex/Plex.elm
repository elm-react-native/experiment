module Plex exposing (..)

import Api exposing (Account, Client, Library, Metadata)
import Browser
import Browser.Navigation as N
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative
    exposing
        ( button
        , fragment
        , image
        , keyboardAvoidingView
        , null
        , pressable
        , require
        , safeAreaView
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
        , component
        , disabled
        , name
        , options
        , placeholder
        , placeholderTextColor
        , secureTextEntry
        , source
        , stringValue
        , style
        , title
        )
import ReactNative.Settings as Settings
import ReactNative.StyleSheet as StyleSheet
import Task exposing (Task)



-- MODEL


type alias Section =
    { info : Library
    , items : List Entity
    }


type Entity
    = Show { info : Metadata, seasons : List Season }
    | Movie Metadata


type alias Season =
    { info : Metadata, episodes : List Metadata }


type Model
    = Initial N.Key
    | SignIn { client : Client, navKey : N.Key, submitting : Bool }
    | Loaded { data : List Section, client : Client, account : Account, navKey : N.Key }


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
    | SignInSubmitFail String
    | SignInSubmitSuccess Account
    | DismissKeyboard
    | LoadSection Section
    | ShowSection String
    | ShowEntity String String


initialClient =
    { serverAddress = "", token = "" }


signInSubmit client =
    Task.attempt
        (\res ->
            case res of
                Ok account ->
                    SignInSubmitSuccess account

                Err (Http.BadUrl _) ->
                    SignInSubmitFail "Server address is invalid."

                Err (Http.BadStatus 401) ->
                    SignInSubmitFail "Token is invalid or expired."

                Err _ ->
                    SignInSubmitFail "Network error."
        )
    <|
        Api.getAccount client


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
                    ( SignIn { client = client, navKey = key, submitting = True }
                    , signInSubmit client
                    )

                SignIn m ->
                    ( SignIn { m | client = client, submitting = True }, signInSubmit client )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitFail err ->
            case model of
                SignIn m ->
                    ( SignIn { m | submitting = False }, Task.perform (always NoOp) <| Alert.alert err [] )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitSuccess account ->
            ( case model of
                SignIn { client, navKey } ->
                    Loaded { data = [], account = account, client = client, navKey = navKey }

                Loaded loaded ->
                    Loaded { loaded | account = account }

                _ ->
                    model
            , Cmd.none
            )

        LoadSection section ->
            ( case model of
                Loaded loaded ->
                    -- TODO: avoid duplicate
                    Loaded { loaded | data = section :: loaded.data }

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


initialScreen _ =
    image [ source <| require "./assets/plex-logo.png" ] []


signInScreen model _ =
    case model of
        SignIn { client, navKey, submitting } ->
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
                            [ text
                                [ style signInStyles.buttonText ]
                                [ str "Sign In" ]
                            ]
                        ]
                    ]
                ]

        _ ->
            null


homeScreen model _ =
    null


root : Model -> Html Msg
root model =
    case model of
        Initial _ ->
            initialScreen model

        _ ->
            stackNavigator "Main" [] <|
                [ screen
                    [ name "signIn"
                    , component signInScreen
                    , options { headerShown = False }
                    ]
                    []
                , screen
                    [ name "home"
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
