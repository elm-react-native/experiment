module ReactNative.Alert exposing (alert)

import Json.Decode as Decode exposing (Decoder)
import Process
import ReactNative exposing (KeyboardType)
import Task exposing (Task)


type alias AlertButton msg =
    { text : String, onPress : Decoder msg, style : AlertButtonStyle }


type AlertButtonStyle
    = DefaultStyle
    | Cancel
    | Destructive


type AlertType
    = DefaultType
    | PlainText
    | SecureText
    | LoginPassword


type alias Options msg =
    { cancelable : Bool, userInterfaceStyle : String, onDismiss : Decoder msg }


alert : String -> Cmd msg
alert message =
    Cmd.none


prompt : String -> Maybe String -> Decoder msg -> Cmd msg
prompt a b c =
    Cmd.none


customizePrompt : String -> Maybe String -> List (AlertButton msg) -> Maybe String -> KeyboardType -> Options msg -> Cmd msg
customizePrompt a b c d e f =
    Cmd.none
