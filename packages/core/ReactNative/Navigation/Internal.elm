module ReactNative.Navigation.Internal exposing (navigatorNode)

import Html exposing (Attribute, Html)


navigatorNode : String -> String -> List (Attribute msg) -> List (Html msg) -> Html msg
navigatorNode tag prefix =
    Html.node tag
