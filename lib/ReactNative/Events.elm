module ReactNative.Events exposing (onClick, onPress, onRefresh, onRequestClose)

import Html.Events exposing (on)


onPress =
    on "press"


onClick =
    on "click"


onRefresh =
    on "refresh"


onRequestClose =
    on "requestClose"
