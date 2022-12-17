module ReactNative.Alert exposing (alert)

import Process
import Task exposing (Task)


alert : String -> Cmd msg
alert message =
    Cmd.none
