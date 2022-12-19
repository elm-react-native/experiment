module ReactNative.PanResponder exposing
    ( create
    , onMoveShouldSetPanResponder
    , onMoveShouldSetPanResponderCapture
    , onPanResponderGrant
    , onPanResponderMove
    , onPanResponderRelease
    , onPanResponderTerminate
    , onPanResponderTerminationRequest
    , onShouldBlockNativeResponder
    , onStartShouldSetPanResponder
    , onStartShouldSetPanResponderCapture
    , prop
    )

import Html exposing (Attribute)
import Html.Attributes exposing (attribute, property)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import ReactNative.Properties exposing (record)


type PanResponder
    = PanResponder


create : List (Attribute msg) -> PanResponder
create _ =
    PanResponder


prop : PanResponder -> Attribute msg
prop =
    property "__panResponder" << record


type InteractionHandle
    = InteractionHandle


getInteractionHandle : PanResponder -> InteractionHandle
getInteractionHandle _ =
    InteractionHandle


attr =
    attribute "" ""


onStartShouldSetPanResponder : Decoder Bool -> Attribute msg
onStartShouldSetPanResponder d =
    attr


onStartShouldSetPanResponderCapture : Decoder Bool -> Attribute msg
onStartShouldSetPanResponderCapture d =
    attr


onMoveShouldSetPanResponder : Decoder Bool -> Attribute msg
onMoveShouldSetPanResponder d =
    attr


onMoveShouldSetPanResponderCapture : Decoder Bool -> Attribute msg
onMoveShouldSetPanResponderCapture d =
    attr


{-| Returns whether this component should block native components from becoming the JS
responder. Returns true by default. Is currently only supported on android.
-}
onShouldBlockNativeResponder : Decoder Bool -> Attribute msg
onShouldBlockNativeResponder d =
    attr


onPanResponderTerminationRequest : Decoder Bool -> Attribute msg
onPanResponderTerminationRequest d =
    attr


{-| The gesture has started. Show visual feedback so the user knows
what is happening!
gestureState.d{x,y} will be set to zero now
-}
onPanResponderGrant =
    on "panResponderGrant"


{-| The most recent move distance is gestureState.move{X,Y}
The accumulated gesture distance since becoming responder is
gestureState.d{x,y}
-}
onPanResponderMove =
    on "panResponderMove"


{-| The user has released all touches while this view is the
responder. This typically means a gesture has succeeded
-}
onPanResponderRelease =
    on "panResponderRelease"


{-| Another component has become the responder, so this gesture
should be cancelled
-}
onPanResponderTerminate =
    on "panResponderTerminate"
