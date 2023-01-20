module ReactNative.Icon exposing (ionicon, materialIcon)

import Html exposing (Attribute, Html)
import ReactNative exposing (node)
import ReactNative.Properties exposing (name)


ionicon : String -> List (Attribute msg) -> Html msg
ionicon n props =
    node "Ionicons" (name n :: props) []


materialIcon : String -> List (Attribute msg) -> Html msg
materialIcon n props =
    node "MaterialIcons" (name n :: props) []
