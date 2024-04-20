module AccountScreen exposing (accountScreen, avatar, avatarStyles)

import Browser
import Browser.Navigation as N
import Client exposing (Client)
import Components exposing (text)
import Dict exposing (Dict)
import Dto exposing (Account, Metadata, Section)
import EntityScreen exposing (entityScreen)
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Model exposing (..)
import ReactNative
    exposing
        ( activityIndicator
        , button
        , image
        , imageBackground
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
        ( behavior
        , color
        , component
        , componentModel
        , contentContainerStyle
        , disabled
        , getId
        , horizontal
        , imageStyle
        , name
        , options
        , persistentScrollbar
        , placeholder
        , placeholderTextColor
        , secureTextEntry
        , showsHorizontalScrollIndicator
        , size
        , source
        , stringValue
        , style
        , title
        )
import ReactNative.Settings as Settings
import ReactNative.StyleSheet as StyleSheet
import Task
import Theme
import Utils exposing (percentFloat)


avatarStyles size =
    StyleSheet.create
        { container =
            { width = size
            , height = size
            , borderRadius = 5
            , backgroundColor = Theme.themeColor
            , justifyContent = "center"
            , alignItems = "center"
            , textAlign = "center"
            , textAlignVertical = "center"
            }
        , text =
            { fontSize = size
            , fontWeight = "bold"
            , lineHeight = size
            }
        }


avatar : { a | name : String, thumb : String } -> b -> Html msg
avatar account size =
    let
        styles =
            avatarStyles size
    in
    if String.isEmpty account.thumb then
        view
            [ style styles.container ]
            [ text
                [ style styles.text ]
                [ str <| String.slice 0 1 account.name ]
            ]

    else
        image
            [ source
                { uri = account.thumb
                , width = size
                , height = size
                , borderRadius = 5
                }
            ]
            []


accountScreen : HomeModel -> a -> Html HomeMsg
accountScreen model _ =
    view
        [ style
            { backgroundColor = Theme.backgroundColor
            , height = "100%"
            , width = "100%"
            , alignItems = "center"
            , paddingTop = 20
            }
        ]
        [ case model.account of
            Just account ->
                avatar account 64

            _ ->
                null
        , button
            [ color "white"
            , title "Sign Out"
            , onPress <| Decode.succeed SignOut
            ]
            []
        , if model.serverHasUpdate then
            button [ color "white", title "Server Update Available", onPress <| Decode.succeed UpdateServer ] []

          else
            null
        , text [] [ str "Version 0.9" ]
        ]
