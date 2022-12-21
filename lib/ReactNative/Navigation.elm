module ReactNative.Navigation exposing (goBack, navigate, popToTop, push)

import Browser.Navigation exposing (Key, back, pushUrl, replaceUrl)


navigate : Key -> String -> Cmd msg
navigate =
    replaceUrl


push : Key -> String -> Cmd msg
push =
    pushUrl


goBack : Key -> Cmd msg
goBack key =
    back key 1


popToTop : Key -> Cmd msg
popToTop key =
    back key -10000
