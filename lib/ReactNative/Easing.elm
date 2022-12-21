module ReactNative.Easing exposing (EasingFunction, bounce, ease)


type alias EasingFunction =
    Float -> Float


ease : EasingFunction
ease =
    identity


bounce : EasingFunction
bounce =
    identity
