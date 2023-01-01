module ReactNative.Navigation exposing (goBack, listeners, navigate, popToTop, push, screenListeners)

import Browser.Navigation exposing (Key, back, pushUrl, replaceUrl)
import ReactNative.Properties exposing (encode, property)


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
