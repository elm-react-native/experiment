module ReactNative.Vibrate exposing (cancel, once, pattern, repeat)


vibrate : List Int -> Bool -> Cmd msg
vibrate p =
    \b ->
        Cmd.none


cancel : Cmd msg
cancel =
    let
        x =
            \() -> Cmd.none
    in
    x ()


once : Cmd msg
once =
    let
        x =
            \() -> Cmd.none
    in
    x ()



--type alias Pattern =
--    { wait : Int
--    , duration : Maybe Int
--    }

pattern : List Int -> Cmd msg
pattern p =
    vibrate p False


repeat : List Int -> Cmd msg
repeat p =
    vibrate p True
