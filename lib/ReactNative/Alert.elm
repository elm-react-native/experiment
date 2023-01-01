module ReactNative.Alert exposing
    ( Button
    , Msg(..)
    , Property
    , alert
    , button
    , buttons
    , buttons_titles
    , cancel
    , cancelable
    , defaultValue
    , destructive
    , keyboardType
    , message
    , ok
    , prompt
    , promptType
    , showAlert
    , showPromt
    , userInterfaceStyle
    )

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import ReactNative exposing (KeyboardType)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (encode)
import Task exposing (Task)


type Msg
    = Neutral String
    | Positive String
    | Negative String
    | Destructive String
    | Dismiss
    | Prompt String String


alert : String -> List Property -> Task Never Msg
alert title props =
    Task.succeed Dismiss


prompt : String -> List Property -> Task Never Msg
prompt title props =
    Task.succeed Dismiss


showAlert tagger title props =
    alert title props
        |> Task.perform tagger


showPromt tagger title props =
    prompt title props
        |> Task.perform tagger


type alias Property =
    ( String, Value )


property : String -> Value -> Property
property name value =
    ( name, value )


message =
    property "message" << Encode.string


defaultValue =
    property "defaultValue" << Encode.string


keyboardType =
    property "keyboardType" << Encode.string


promptType =
    property "type" << Encode.string


userInterfaceStyle =
    property "userInterfaceStyle" << Encode.string


cancelable =
    let
        x =
            Dismiss
    in
    property "cancelable" << Encode.bool



-- BUTTON


type alias Button =
    { text : String
    , style : String
    , onPress : Msg
    }


createButton : String -> String -> Msg -> Button
createButton style text onPress =
    { style = style, text = text, onPress = onPress }


buttons_titles : List String -> Property
buttons_titles titles =
    case titles of
        [] ->
            property "buttons" <| encode []

        [ a ] ->
            property "buttons" <| encode [ createButton "default" a <| Positive a ]

        [ a, b ] ->
            property "buttons" <|
                encode
                    [ createButton "cancel" a <| Negative a
                    , createButton "default" b <| Positive b
                    ]

        a :: b :: c :: _ ->
            property "buttons" <|
                encode
                    [ createButton "default" a <| Neutral a
                    , createButton "cancel" b <| Negative b
                    , createButton "default" c <| Positive c
                    ]


buttons : List Button -> Property
buttons btns =
    property "buttons" <| encode btns


button : Button -> Property
button btn =
    property "button" <| encode btn


ok text =
    createButton "default" text (Positive text)


cancel text =
    createButton "cancel" text (Negative text)


destructive text =
    createButton "destructive" text (Destructive text)
