module InputAccessoryViewExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import ReactNative exposing (button, fragment, inputAccessoryView, scrollView, str, text, textInput, view)
import ReactNative.Events exposing (onChangeText, onPress)
import ReactNative.Properties exposing (inputAccessoryViewID, keyboardDismissMode, nativeID, placeholder, stringValue, style, title)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { text : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { text = initialText }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | SetText String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetText s ->
            ( { model | text = s }, Cmd.none )


uniqueID =
    "uniqueID"


initialText =
    ""



-- VIEW


root : Model -> Html Msg
root model =
    fragment []
        [ scrollView [ keyboardDismissMode "interactive" ]
            [ textInput
                [ style { padding = 16, marginTop = 30 }
                , inputAccessoryViewID uniqueID
                , onChangeText SetText
                , stringValue model.text
                , placeholder "Please type here..."
                ]
                []
            ]
        , inputAccessoryView [ nativeID uniqueID ]
            [ button
                [ title "Clear text"
                , onPress <| Decode.succeed <| SetText initialText
                ]
                []
            ]
        ]


subs _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
