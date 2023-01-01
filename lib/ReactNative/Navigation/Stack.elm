module ReactNative.Navigation.Stack exposing (navigator, screen)

import Html exposing (Attribute, Html, node)
import ReactNative.Properties exposing (encode, property)


navigator =
    node "Stack.Navigator"


screen =
    node "Stack.Screen"
