module ReactNative.Appearance exposing
    ( ColorScheme(..)
    , encodeColorScheme
    , getColorScheme
    , onChange
    )

import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Task exposing (Task)


type ColorScheme
    = Light
    | Dark
    | NotIndicated


getColorScheme : Task Never ColorScheme
getColorScheme =
    let
        x =
            Dark
    in
    Task.succeed x


colorSchemeDecoder : Decoder ColorScheme
colorSchemeDecoder =
    Decode.map
        (\s ->
            case s of
                "light" ->
                    Light

                "dark" ->
                    Dark

                _ ->
                    NotIndicated
        )
        Decode.string


encodeColorScheme : ColorScheme -> Encode.Value
encodeColorScheme state =
    case state of
        Light ->
            Encode.string "light"

        Dark ->
            Encode.string "dark"

        NotIndicated ->
            Encode.null


onChange : (ColorScheme -> msg) -> Sub msg
onChange tagger =
    onMouseDown (Decode.map tagger colorSchemeDecoder)
