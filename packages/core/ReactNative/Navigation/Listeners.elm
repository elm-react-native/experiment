module ReactNative.Navigation.Listeners exposing (beforeRemove, blur, focus, state)

import Html.Events exposing (on)


state =
    on "state"


focus =
    on "focus"


blur =
    on "blur"


beforeRemove =
    on "beforeRemove"
