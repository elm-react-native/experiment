module Utils exposing (charAt, formatDuration, generateIdentifier, maybeEmptyList, maybeEmptyString, maybeFalse, maybeFloatZero, maybeWithDefault, maybeZero, percentFloat, quotRem)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Random


charAt : Int -> String -> Maybe Char
charAt i s =
    Maybe.map Tuple.first <| String.uncons <| String.slice i (i + 1) s


generateIdentifier : Random.Generator String
generateIdentifier =
    {-
       This is how the offical plex web client generate the clientId:

       function i(e=24) {
           const t = (0, n.Z)(e, 0, 1024);
           let r = "";
           for (; r.length < t;)
               r += Math.random().toString(36).substring(2, t - r.length + 2);
           return r
       }

       n.Z = function(e, t, r) {
           return Math.max(Math.min(e, r), t)
       }
    -}
    let
        toChar n =
            if n < 10 then
                Char.fromCode <| 48 + n

            else
                Char.fromCode <| 97 + (n - 10)
    in
    Random.int 0 35
        |> Random.map toChar
        |> Random.list 24
        |> Random.map String.fromList


maybeWithDefault : a -> Decoder a -> Decoder a
maybeWithDefault defaultValue decoder =
    Decode.map (Maybe.withDefault defaultValue) <| Decode.maybe decoder


maybeEmptyString : Decoder String -> Decoder String
maybeEmptyString =
    maybeWithDefault ""


maybeZero : Decoder Int -> Decoder Int
maybeZero =
    maybeWithDefault 0


maybeFloatZero : Decoder Float -> Decoder Float
maybeFloatZero =
    maybeWithDefault 0.0


maybeFalse : Decoder Bool -> Decoder Bool
maybeFalse =
    maybeWithDefault False


maybeEmptyList : Decoder (List a) -> Decoder (List a)
maybeEmptyList =
    maybeWithDefault []


percentFloat : Float -> String
percentFloat f =
    (String.fromInt <| ceiling <| f * 100) ++ "%"


quotRem : Int -> Int -> ( Int, Int )
quotRem a b =
    ( a // b, remainderBy b a )


formatDuration : Int -> String
formatDuration duration =
    let
        ( h, ms ) =
            quotRem duration (3600 * 1000)

        ( m, ms2 ) =
            quotRem ms (60 * 1000)

        s =
            ms2 // 1000
    in
    if h == 0 && m == 0 && s > 0 then
        String.fromInt s ++ "s"

    else if h == 0 && m > 0 then
        String.fromInt m ++ "m"

    else if h > 0 && m == 0 then
        String.fromInt h ++ "h"

    else
        String.fromInt h ++ "h " ++ String.fromInt m ++ "m"
