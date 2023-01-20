module ReactNative.DrawerLayoutAndroid exposing (close, open)

import Task exposing (Task)


open : String -> Task Never ()
open id =
    Task.succeed ()


close : String -> Task Never ()
close id =
    Task.succeed ()
