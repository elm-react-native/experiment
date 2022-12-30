module ReactNative.Events exposing (onClick, onPress, onRefresh, onRequestClose, onSubmitEditing)

import Html.Events exposing (on)


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
