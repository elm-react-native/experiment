module Utils exposing (..)


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
