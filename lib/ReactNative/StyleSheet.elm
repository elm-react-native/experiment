module ReactNative.StyleSheet exposing (absoluteFill, compose, create, hairlineWidth)


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
