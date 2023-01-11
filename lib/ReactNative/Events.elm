module ReactNative.Events exposing
    ( on
    , onAccessibilityAction
    , onAccessibilityEscape
    , onAccessibilityTap
    , onBlur
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
    , onFocus
    , onLayout
    , onLongPress
    , onMagicTap
    , onMoveShouldSetResponder
    , onMoveShouldSetResponderCapture
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
    , onSubmitEditing
    , onViewableItemsChanged
    )

import Html exposing (Attribute)
import Html.Events
import Json.Decode as Decode


on =
    Html.Events.on


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
onBoolValueChange tagger =
    on "valueChange" <| Decode.map tagger Decode.bool


onChangeText : (String -> msg) -> Attribute msg
onChangeText tagger =
    on "changeText" <| Decode.map tagger Decode.string


onDrawerOpen : msg -> Attribute msg
onDrawerOpen msg =
    on "drawerOpen" <| Decode.succeed msg


onDrawerClose : msg -> Attribute msg
onDrawerClose msg =
    on "drawerClose" <| Decode.succeed msg


onDrawerSlide : msg -> Attribute msg
onDrawerSlide msg =
    on "drawerSlide" <| Decode.succeed msg


onDrawerStateChange : (String -> msg) -> Attribute msg
onDrawerStateChange tagger =
    on "drawerStateChange" <| Decode.map tagger Decode.string


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
