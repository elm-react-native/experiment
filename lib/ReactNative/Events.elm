module ReactNative.Events exposing (onClick, onPress, onRefresh)

import Html.Events exposing (on)


onPress =
    on "press"


onClick =
    on "click"


onRefresh =
    on "refresh"
