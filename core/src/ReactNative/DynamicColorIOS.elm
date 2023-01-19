module ReactNative.DynamicColorIOS exposing (set, setWithHighContrast)

import Task exposing (Task)


set : String -> String -> Cmd msg
set light dark =
    setWithHighContrast light dark Nothing Nothing


setWithHighContrast : String -> String -> Maybe String -> Maybe String -> Cmd msg
setWithHighContrast light dark highContrastLight highContrastDark =
    Cmd.none
