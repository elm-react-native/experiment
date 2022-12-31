module ReactNative.StyleSheet exposing (absoluteFill, compose, compose3, create, hairlineWidth)


create : a -> a
create =
    identity


hairlineWidth =
    0


absoluteFill =
    {}


compose : a -> b -> b
compose a b =
    b


compose3 : a -> b -> c -> c
compose3 a b c =
    c
