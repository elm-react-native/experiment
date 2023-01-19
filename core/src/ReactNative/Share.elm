module ReactNative.Share exposing
    ( Action(..)
    , Result
    , dialogTitle
    , excludedActivityTypes
    , message
    , share
    , subject
    , tintColor
    , title
    , url
    )

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Task exposing (Task)


type Action
    = SharedAction
    | DismissedAction


toAction s =
    case s of
        "sharedAction" ->
            SharedAction

        "dismissedAction" ->
            DismissedAction

        _ ->
            SharedAction


type alias Result =
    { action : Action
    , activityType : String
    }


type alias Property =
    ( String, Value )


property name value =
    ( name, value )


message =
    property "message" << Encode.string


url =
    property "url" << Encode.string


dialogTitle =
    property "dialogTitle" << Encode.string


title =
    property "title" << Encode.string


subject =
    property "subject" << Encode.string


tintColor =
    property "tintColor" << Encode.string


excludedActivityTypes =
    property "excludedActivityTypes" << Encode.list Encode.string


share : List Property -> Task String Result
share props =
    let
        x =
            toAction
    in
    Task.fail ""
