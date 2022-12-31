module ReactNative.Events exposing
    ( onBoolValueChange
    , onChangeText
    , onClick
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
    on "valueChange" (Decode.map tagger Decode.bool)


onChangeText : (String -> msg) -> Attribute msg
onChangeText tagger =
    on "changeText" (Decode.map tagger Decode.string)
