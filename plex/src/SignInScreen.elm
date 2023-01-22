module SignInScreen exposing (signInScreen, signInStyles)

import AccountScreen exposing (accountScreen, avatar)
import Api exposing (Client, Metadata)
import Browser
import Browser.Navigation as N
import Dict exposing (Dict)
import EntityScreen exposing (entityScreen)
import HomeScreen exposing (homeScreen)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (..)
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
        , text
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
import Task
import Theme


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
            { color = "white", fontSize = 16, fontWeight = "bold" }
        }


signInScreen : SignInModel -> Html Msg
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
                    , onChangeText SignInInputEmail
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
                    , onChangeText SignInInputPassword
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
                    , onPress <| Decode.succeed SignInSubmit
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
