module ReactNative.Events exposing
    ( onBoolValueChange
    , onChangeText
    , onClick
    , onDrawerClose
    , onDrawerOpen
    , onDrawerSlide
    , onDrawerStateChange
    , onLongPress
    , onPress
    , onPressIn
    , onPressOut
    , onRefresh
    , onRequestClose
    , onSubmitEditing
    )

import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as Decode


onPress =
    on "press"


onPressIn =
    on "pressIn"


onPressOut =
    on "pressOut"


onLongPress =
    on "longPress"


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
