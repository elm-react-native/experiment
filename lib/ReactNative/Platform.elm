module ReactNative.Platform exposing
    ( color
    , constants
    , isPad
    , isTV
    , isTesting
    , os
    , select
    , version
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


os =
    ""


select : a -> a
select =
    identity


version : Float
version =
    0


isTV =
    False


isPad =
    False


isTesting =
    False


constants : String
constants =
    let
        x =
            ""
    in
    x


color : String -> String
color =
    identity


colors : String -> List String -> String
colors c failbacks =
    color c
