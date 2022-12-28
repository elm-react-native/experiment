module ReactNative.Navigation.Stack exposing (listeners, navigator, screen, screenListeners)

import Html exposing (Attribute, Html, node)
import ReactNative.Properties exposing (encode, property)


navigator =
    node "Stack.Navigator"


screen =
    node "Stack.Screen"


listeners =
    property "listeners" << encode


screenListeners =
    property "screenListeners" << encode
