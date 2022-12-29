module ReactNative.Animated exposing
    ( AnimationResult
    , Value
    , create
    , createXY
    , event
    , event2
    , getLayout
    , interpolate
    , mapping
    , reset
    , setValue
    , spring
    , start
    , timing
    , view
    )

import Html exposing (Attribute, node)
import Html.Attributes exposing (attribute)
import Json.Decode as Decode exposing (Decoder)
import ReactNative.Easing as Easing exposing (EasingFunction)
import Task exposing (Task)


type Value
    = Value
    | ValueXY


create : Float -> Value
create x =
    Value


createXY : Float -> Float -> Value
createXY x y =
    ValueXY


getLayout : Value -> { left : Value, top : Value }
getLayout v =
    { left = v, top = v }


mapping : (Value -> a) -> Value -> Value
mapping fn b =
    b


view =
    node "Animated.View"



--add : Value -> Value -> Value
--add a b =
--    a
--subtract : Value -> Value -> Value
--subtract a b =
--    a
--multiply : Value -> Value -> Value
--multiply a b =
--    a
--modulo : Value -> Value -> Value
--modulo a b =
--    a
--diffClamp : Int -> Int -> Value -> Value
--diffClamp min max a =
--    a


interpolate : cfg -> Value -> Value
interpolate cfg v =
    v


setValue : Float -> Value -> Value
setValue f =
    identity


loop : Int -> Value -> Value
loop i =
    identity


timing : cfg -> Value -> Value
timing cfg v =
    v


spring : cfg -> Value -> Value
spring cfg v =
    v


type alias AnimationResult =
    { finished : Bool }


start : Value -> Task Never AnimationResult
start v =
    Task.succeed { finished = False }


reset : Value -> Task Never ()
reset v =
    Task.succeed ()


stop : Value -> Task Never ()
stop v =
    Task.succeed ()


delay : Int -> Value -> Task Never AnimationResult
delay s v =
    Task.succeed { finished = False }


event : m -> Decoder msg -> Decoder msg
event m d =
    d


event2 : a -> b -> Decoder msg -> Decoder msg
event2 a b d =
    d
