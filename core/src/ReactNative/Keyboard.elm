module ReactNative.Keyboard exposing
    ( dismiss
    , onDidChangeFrame
    , onDidHide
    , onDidShow
    , onWillChangeFrame
    , onWillHide
    , onWillShow
    )

import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Task exposing (Task)


on : String -> Decoder msg -> Sub msg
on event decoder =
    onMouseDown decoder


onDidChangeFrame =
    on "keyboardDidChangeFrame"


onDidHide =
    on "keyboardDidHide"


onDidShow =
    on "keyboardDidShow"


onWillChangeFrame =
    on "keyboardWillChangeFrame"


onWillHide =
    on "keyboardWillHide"


onWillShow =
    on "keyboardWillShow"


dismiss : Task Never ()
dismiss =
    let
        x =
            ()
    in
    Task.succeed x
