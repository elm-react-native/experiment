module ReactNative.Easing exposing
    ( EasingFunction
    , back
    , bezier
    , bounce
    , circle
    , cubic
    , ease
    , elastic
    , exp
    , inOut
    , in_
    , linear
    , out
    , poly
    , quad
    , sin
    )


type alias EasingFunction =
    Float -> Float


ease : EasingFunction
ease =
    identity


bounce : EasingFunction
bounce =
    identity


elastic : Int -> EasingFunction
elastic n =
    identity


poly : Int -> EasingFunction
poly n =
    identity


linear : EasingFunction
linear =
    identity


quad : EasingFunction
quad =
    identity


bezier : ( Int, Int ) -> ( Int, Int ) -> EasingFunction
bezier p1 p2 =
    identity


cubic : EasingFunction
cubic =
    identity


back : EasingFunction
back =
    identity


circle : EasingFunction
circle =
    identity


sin : EasingFunction
sin =
    identity


exp : EasingFunction
exp =
    identity


in_ : EasingFunction -> EasingFunction
in_ f =
    f


out : EasingFunction -> EasingFunction
out f =
    f


inOut : EasingFunction -> EasingFunction
inOut f =
    f
