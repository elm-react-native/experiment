module ReactNative.Events exposing (onClick, onPress, onRefresh, onRequestClose, onSubmitEditing, onValueChange)

import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as Decode


onPress =
    on "press"


onClick =
    on "click"


onRefresh =
    on "refresh"


onRequestClose =
    on "requestClose"


onSubmitEditing =
    on "submitEditing"


onValueChange : (Bool -> msg) -> Attribute msg
onValueChange tagger =
    on "valueChange" (Decode.map tagger Decode.bool)
