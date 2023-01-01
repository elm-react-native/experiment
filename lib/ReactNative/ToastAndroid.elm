module ReactNative.ToastAndroid exposing
    ( Gravity(..)
    , durationLong
    , durationShort
    , show
    , showWithGravity
    , showWithGravityAndOffset
    )

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import ReactNative exposing (KeyboardType)
import ReactNative.Properties exposing (encode)
import Task exposing (Task)


type Gravity
    = Top
    | Center
    | Bottom


toGravity : Gravity -> Int
toGravity gravity =
    case gravity of
        Top ->
            0

        Center ->
            1

        Bottom ->
            2


show : String -> Int -> Task Never ()
show msg duration =
    Task.succeed ()


showWithGravity : String -> Int -> Gravity -> Task Never ()
showWithGravity msg duration gravity =
    let
        g =
            toGravity gravity
    in
    Task.succeed ()


showWithGravityAndOffset : String -> Int -> Gravity -> Float -> Float -> Task Never ()
showWithGravityAndOffset msg duration gravity xOffset yOffset =
    let
        g =
            toGravity gravity
    in
    Task.succeed ()


durationShort =
    0


durationLong =
    0
