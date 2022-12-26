module ReactNative.AppState exposing (AppState(..), decoder, encode, onChange)

import Browser
import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type AppState
    = Active
    | Background
    | Inactive


decoder : Decoder AppState
decoder =
    Decode.map
        (\s ->
            case s of
                "active" ->
                    Active

                "background" ->
                    Background

                _ ->
                    Inactive
        )
        Decode.string


encode : AppState -> Encode.Value
encode state =
    case state of
        Active ->
            Encode.string "active"

        Background ->
            Encode.string "background"

        Inactive ->
            Encode.string "inactive"


onChange : (AppState -> msg) -> Sub msg
onChange func =
    onMouseDown (Decode.map func decoder)
