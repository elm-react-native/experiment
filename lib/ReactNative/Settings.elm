module ReactNative.Settings exposing (get, set, watchKey)

import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Task exposing (Task)


get : String -> Decoder data -> Task Decode.Error data
get k decoder =
    Task.fail <| Decode.Failure "" Encode.null


set : List ( String, Value ) -> Task Never ()
set settings =
    Task.succeed ()


watchKey : String -> Decoder msg -> Sub msg
watchKey key decoder =
    onMouseDown decoder
