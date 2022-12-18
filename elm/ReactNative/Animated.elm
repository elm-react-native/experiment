module ReactNative.Animated exposing
    ( AnimationResult
    , Value
    , create
    , defaultSpringConfig
    , defaultTimingConfig
    , spring
    , start
    , timing
    , view
    )

import Html exposing (node)
import ReactNative.Easing as Easing exposing (EasingFunction)
import Task exposing (Task)


type Value
    = Value


type alias EasingFunction =
    Float -> Float


type alias TimingConfig =
    { toValue : Float
    , duration : Int
    , easing : EasingFunction
    , delay : Int
    , isInteraction : Bool
    , useNativeDriver : Bool
    }


defaultTimingConfig : TimingConfig
defaultTimingConfig =
    { toValue = 0
    , duration = 500
    , easing = Easing.ease
    , delay = 0
    , isInteraction = False
    , useNativeDriver = False
    }


type alias SpringConfig =
    { toValue : Float
    , friction : Int
    , tension : Int
    , speed : Int
    , bounciness : Int
    , stiffness : Int
    , damping : Int
    , mass : Int
    , velocity : Int
    , restDisplacementThreshold : Float
    , restSpeedThreshold : Float
    , delay : Int
    , isInteraction : Bool
    , useNativeDriver : Bool
    }


defaultSpringConfig : SpringConfig
defaultSpringConfig =
    { toValue = 0
    , friction = 7
    , tension = 40
    , speed = 12
    , bounciness = 8
    , stiffness = 100
    , damping = 10
    , mass = 1
    , velocity = 0
    , restDisplacementThreshold = 0.001
    , restSpeedThreshold = 0.001
    , delay = 0
    , isInteraction = True
    , useNativeDriver = False
    }


create : Float -> Value
create x =
    Value


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


reset : Value -> Value
reset =
    identity


loop : Int -> Value -> Value
loop i =
    identity


timing : TimingConfig -> Value -> Value
timing cft =
    identity


spring : SpringConfig -> Value -> Value
spring cfg =
    identity


type alias AnimationResult =
    { finished : Bool }


start : Value -> Task Never AnimationResult
start v =
    Task.succeed { finished = False }



-- FIXME: ?? should stop kill the start task


stop : Value -> Task Never AnimationResult
stop v =
    Task.succeed { finished = False }


delay : Int -> Value -> Task Never AnimationResult
delay s v =
    Task.succeed { finished = False }
