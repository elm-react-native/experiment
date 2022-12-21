module ReactNative.Platform exposing (color, isPad, isTV, isTesting, os, select, version)


os =
    ""


select : a -> a
select =
    identity


version =
    {}


isTV =
    False


isPad =
    False


isTesting =
    False


color : String -> String
color =
    identity


colors : String -> List String -> String
colors c failbacks =
    color c
