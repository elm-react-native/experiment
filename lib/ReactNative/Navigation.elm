module ReactNative.Navigation exposing
    ( drawerNavigator
    , goBack
    , listeners
    , navigate
    , popToTop
    , push
    , screen
    , screenListeners
    , stackNavigator
    , tabNavigator
    )

import Browser.Navigation exposing (Key, back, pushUrl, replaceUrl)
import Html exposing (Attribute, Html, node)
import ReactNative.Navigation.Internal exposing (navigatorNode)
import ReactNative.Properties exposing (encode, property)


screen =
    node "Screen"


stackNavigator =
    navigatorNode "Stack"


tabNavigator =
    navigatorNode "Tab"


drawerNavigator =
    navigatorNode "Drawer"


navigate : Key -> String -> Cmd msg
navigate =
    replaceUrl


push : Key -> String -> p -> Cmd msg
push k s p =
    pushUrl k s


goBack : Key -> Cmd msg
goBack key =
    back key 1


popToTop : Key -> Cmd msg
popToTop key =
    back key -10000


listeners =
    property "listeners" << encode


screenListeners =
    property "screenListeners" << encode
