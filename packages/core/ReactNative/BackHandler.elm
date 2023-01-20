module ReactNative.BackHandler exposing (exitApp, onHardwareBackPress)

import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


onHardwareBackPress : msg -> Sub msg
onHardwareBackPress msg =
    onMouseDown (Decode.succeed msg)


exitApp : Cmd msg
exitApp =
    let
        x =
            0
    in
    Cmd.none
