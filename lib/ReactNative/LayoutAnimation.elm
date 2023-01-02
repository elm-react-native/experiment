module ReactNative.LayoutAnimation exposing
    ( Config
    , config
    , configureNext
    , easeInEaseOut
    , linear
    , setLayoutAnimationEnabledExperimental
    , spring
    )

import Task exposing (Task)



--if (
--  Platform.OS === "android" &&
--  UIManager.setLayoutAnimationEnabledExperimental
--) {
--  UIManager.setLayoutAnimationEnabledExperimental(true);
--}


setLayoutAnimationEnabledExperimental : Bool -> Cmd msg
setLayoutAnimationEnabledExperimental b =
    Cmd.none


type Config
    = Config


configureNext : Config -> Task () ()
configureNext cfg =
    Task.succeed ()


config : { c | duration : Int } -> Config
config c =
    Config


easeInEaseOut =
    Config


linear =
    Config


spring =
    Config
