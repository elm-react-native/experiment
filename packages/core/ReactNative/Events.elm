module ReactNative.Events exposing
    ( on
    , onAccessibilityAction
    , onAccessibilityEscape
    , onAccessibilityTap
    , onBlur
    , onBool
    , onBoolValueChange
    , onChangeText
    , onClick
    , onDismiss
    , onDrawerClose
    , onDrawerOpen
    , onDrawerSlide
    , onDrawerStateChange
    , onEndReached
    , onError
    , onFloat
    , onFloatValueChange
    , onFocus
    , onInt
    , onIntValueChange
    , onLayout
    , onLongPress
    , onMagicTap
    , onMoveShouldSetResponder
    , onMoveShouldSetResponderCapture
    , onMsg
    , onOrientationChange
    , onPress
    , onPressIn
    , onPressOut
    , onRefresh
    , onRequestClose
    , onResponderGrant
    , onResponderMove
    , onResponderReject
    , onResponderRelease
    , onResponderTerminate
    , onResponderTerminationRequest
    , onScrollToIndexFailed
    , onStartShouldSetResponder
    , onStartShouldSetResponderCapture
    , onString
    , onStringValueChange
    , onSubmitEditing
    , onViewableItemsChanged
    )

import Html exposing (Attribute)
import Html.Events
import Json.Decode as Decode


on =
    Html.Events.on


onString event tagger =
    on event <| Decode.map tagger Decode.string


onInt event tagger =
    on event <| Decode.map tagger Decode.int


onFloat event tagger =
    on event <| Decode.map tagger Decode.float


onBool event tagger =
    on event <| Decode.map tagger Decode.bool


onMsg event msg =
    on event <| Decode.succeed msg


onPress =
    on "press"


onPressIn =
    on "pressIn"


onPressOut =
    on "pressOut"


onLongPress =
    on "longPress"


onFocus =
    on "focus"


onBlur =
    on "blur"


onClick =
    on "click"


onRefresh =
    on "refresh"


onRequestClose =
    on "requestClose"


onSubmitEditing =
    on "submitEditing"


onBoolValueChange : (Bool -> msg) -> Attribute msg
onBoolValueChange =
    onBool "valueChange"


onIntValueChange : (Int -> msg) -> Attribute msg
onIntValueChange =
    onInt "valueChange"


onFloatValueChange : (Float -> msg) -> Attribute msg
onFloatValueChange =
    onFloat "valueChange"


onStringValueChange : (String -> msg) -> Attribute msg
onStringValueChange =
    onString "valueChange"


onChangeText : (String -> msg) -> Attribute msg
onChangeText =
    onString "changeText"


onDrawerOpen : msg -> Attribute msg
onDrawerOpen =
    onMsg "drawerOpen"


onDrawerClose : msg -> Attribute msg
onDrawerClose =
    onMsg "drawerClose"


onDrawerSlide : msg -> Attribute msg
onDrawerSlide =
    onMsg "drawerSlide"


onDrawerStateChange : (String -> msg) -> Attribute msg
onDrawerStateChange =
    onString "drawerStateChange"


onDismiss =
    on "dismiss"


onOrientationChange =
    on "orientationChange"


onAccessibilityAction =
    on "accessibilityAction"


onAccessibilityEscape =
    on "accessibilityEscape"


onAccessibilityTap =
    on "accessibilityTap"


onLayout =
    on "layout"


onMagicTap =
    on "magicTap"


onMoveShouldSetResponder =
    on "moveShouldSetResponder"


onMoveShouldSetResponderCapture =
    on "moveShouldSetResponderCapture"


onResponderGrant =
    on "responderGrant"


onResponderMove =
    on "responderMove"


onResponderReject =
    on "responderReject"


onResponderRelease =
    on "responderRelease"


onResponderTerminate =
    on "responderTerminate"


onResponderTerminationRequest =
    on "responderTerminationRequest"


onStartShouldSetResponder =
    on "startShouldSetResponder"


onStartShouldSetResponderCapture =
    on "startShouldSetResponderCapture"


onEndReached =
    on "endReached"


onScrollToIndexFailed =
    on "scrollToIndexFailed"


onViewableItemsChanged =
    on "viewableItemsChanged"


onError =
    on "error"
