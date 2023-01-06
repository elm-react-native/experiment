module ReactNative.Navigation.CardStyleInterpolators exposing (..)


type CardStyleInterpolator
    = CardStyleInterpolator


{-| Standard iOS-style slide in from the right.
-}
forHorizontalIOS =
    CardStyleInterpolator


{-| Standard iOS-style slide in from the bottom (used for modals).
-}
forVerticalIOS =
    CardStyleInterpolator


{-| Standard iOS-style modal animation in iOS 13.
-}
forModalPresentationIOS =
    CardStyleInterpolator


{-| Standard Android-style fade in from the bottom for Android Oreo.
-}
forFadeFromBottomAndroid =
    CardStyleInterpolator


{-| Standard Android-style reveal from the bottom for Android Pie.
-}
forRevealFromBottomAndroid =
    CardStyleInterpolator
