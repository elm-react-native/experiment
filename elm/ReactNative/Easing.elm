module ReactNative.Easing exposing (EasingFunction, ease)


type alias EasingFunction =
    Float -> Float


ease : EasingFunction
ease =
    identity


bounce : EasingFunction
bounce =
    identity
