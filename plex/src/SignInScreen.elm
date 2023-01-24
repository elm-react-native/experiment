module SignInScreen exposing (signInScreen, signInStyles, signInUpdate)

import AccountScreen exposing (accountScreen, avatar)
import Api exposing (Client, Metadata)
import Browser
import Browser.Navigation as N
import Components exposing (text)
import Dict exposing (Dict)
import EntityScreen exposing (entityScreen)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative
    exposing
        ( activityIndicator
        , button
        , image
        , keyboardAvoidingView
        , null
        , require
        , scrollView
        , str
        , textInput
        , touchableOpacity
        , touchableWithoutFeedback
        , view
        )
import ReactNative.ActionSheetIOS as ActionSheetIOS
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onChangeText, onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Properties
    exposing
        ( autoCapitalize
        , autoCorrect
        , behavior
        , color
        , component
        , componentModel
        , contentContainerStyle
        , disabled
        , getId
        , inputMode
        , name
        , options
        , placeholder
        , placeholderTextColor
        , secureTextEntry
        , size
        , source
        , stringValue
        , style
        , textContentType
        , title
        )
import ReactNative.Settings as Settings
import ReactNative.StyleSheet as StyleSheet
import SignInModel exposing (SignInModel, SignInMsg(..))
import Task
import Theme


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


signInSubmit : Client -> Cmd SignInMsg
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
        |> Task.attempt SubmitResponse


signInUpdate : SignInMsg -> SignInModel -> ( SignInModel, Cmd SignInMsg )
signInUpdate msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        InputEmail email ->
            let
                client =
                    model.client
            in
            ( { model | client = { client | email = email } }, Cmd.none )

        InputPassword password ->
            let
                client =
                    model.client
            in
            ( { model | client = { client | password = password } }, Cmd.none )

        Submit ->
            ( { model | submitting = True }, signInSubmit model.client )

        GotClientId id ->
            let
                client =
                    model.client
            in
            ( { model | client = { client | id = id } }, Cmd.none )

        DismissKeyboard ->
            ( model, Task.perform (always NoOp) Keyboard.dismiss )

        SubmitResponse (Err err) ->
            let
                errMessage =
                    case err of
                        Http.BadStatus 401 ->
                            "Email or password is wrong."

                        _ ->
                            "Network error."
            in
            ( { model | submitting = False }, Alert.showAlert (always NoOp) errMessage [] )

        SubmitResponse _ ->
            ( model, Cmd.none )


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
            , fontFamily = Theme.fontFamily
            , height = 44
            , marginBottom = 20
            , color = "white"
            , borderColor = Theme.themeColor
            }
        , button =
            { backgroundColor = Theme.themeColor
            , height = 44
            , borderRadius = 3
            , justifyContent = "center"
            , alignItems = "center"
            }
        , buttonDisabled =
            { opacity = 0.5 }
        , buttonText =
            { fontSize = 16, fontWeight = "bold" }
        }


signInScreen : SignInModel -> Html SignInMsg
signInScreen { client, submitting } =
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
                    , placeholder "Email"
                    , placeholderTextColor "#555"
                    , stringValue client.email
                    , onChangeText InputEmail
                    , inputMode "email"
                    , autoCorrect False
                    , autoCapitalize "none"
                    , textContentType "emailAddress"
                    ]
                    []
                , textInput
                    [ style signInStyles.input
                    , disabled submitting
                    , placeholder "Password"
                    , placeholderTextColor "#555"
                    , stringValue client.password
                    , secureTextEntry True
                    , onChangeText InputPassword
                    , textContentType "password"
                    ]
                    []
                , let
                    buttonDisabled =
                        submitting
                            || String.isEmpty client.email
                            || String.isEmpty client.password
                  in
                  touchableOpacity
                    [ if buttonDisabled then
                        style <| StyleSheet.compose signInStyles.button signInStyles.buttonDisabled

                      else
                        style signInStyles.button
                    , disabled buttonDisabled
                    , onPress <| Decode.succeed Submit
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
