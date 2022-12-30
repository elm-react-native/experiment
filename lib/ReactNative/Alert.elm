module ReactNative.Alert exposing
    ( AlertButton
    , Options
    , PromptOption
    , alert
    , cancelButton
    , destructiveButton
    , okButton
    , prompt
    , show
    , tshow
    , withButtons
    , withMessage
    , withOptions
    , withPrompt
    )

import Process
import ReactNative exposing (KeyboardType)
import Task exposing (Task)


type alias AlertButton msg =
    { text : String
    , onPress : Maybe msg
    , style : String
    }


type alias Options msg =
    { cancelable : Bool
    , userInterfaceStyle : String
    , onDismiss : Maybe msg
    }


type alias PromptOption =
    { type_ : String
    , defaultValue : String
    , keyboardType : String
    }


type Alert msg
    = Alert
        { title : String
        , message : Maybe String
        , buttons : List (AlertButton msg)
        , options : Maybe (Options msg)
        , prompt : Maybe PromptOption
        }


alert : String -> Alert msg
alert title =
    Alert
        { title = title
        , message = Nothing
        , buttons = []
        , options = Nothing
        , prompt = Nothing
        }


prompt : PromptOption -> String -> Alert msg
prompt pt title =
    Alert
        { title = title
        , message = Nothing
        , buttons = []
        , options = Nothing
        , prompt = Just pt
        }


withMessage : String -> Alert msg -> Alert msg
withMessage message (Alert a) =
    Alert { a | message = Just message }


withButtons : List (AlertButton msg) -> Alert msg -> Alert msg
withButtons buttons (Alert a) =
    Alert { a | buttons = buttons }


button : String -> String -> Maybe msg -> AlertButton msg
button style text onPress =
    { style = style, text = text, onPress = onPress }


cancelButton =
    button "cancel"


okButton =
    button "default"


destructiveButton =
    button "destructive"


withOptions : Bool -> String -> Maybe msg -> Alert msg -> Alert msg
withOptions cancelable userInterfaceStyle onDismiss (Alert a) =
    Alert
        { a
            | options =
                Just
                    { cancelable = cancelable
                    , userInterfaceStyle = userInterfaceStyle
                    , onDismiss = onDismiss
                    }
        }


withPrompt : PromptOption -> Alert msg -> Alert msg
withPrompt pt (Alert a) =
    Alert { a | prompt = Just pt }


tshow : Alert msg -> Task Never (Maybe msg)
tshow a =
    Task.succeed Nothing


show : (Maybe msg -> msg1) -> Alert msg -> Cmd msg1
show f =
    tshow >> Task.perform f
