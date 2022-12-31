module ReactNative.Linking exposing (canOpenURL, getInitialURL, openSettings, openURL, sendIntent)

import Json.Encode as Encode exposing (Value)
import Task exposing (Task)


openURL : String -> Task Never ()
openURL url =
    Task.succeed ()


openSettings : Task Never ()
openSettings =
    let
        x =
            ()
    in
    Task.succeed x


canOpenURL : String -> Task Never Bool
canOpenURL url =
    Task.succeed False


getInitialURL : Task Never String
getInitialURL =
    let
        x =
            ""
    in
    Task.succeed x


sendIntent : String -> Value -> Task Never ()
sendIntent action extras =
    Task.succeed ()
