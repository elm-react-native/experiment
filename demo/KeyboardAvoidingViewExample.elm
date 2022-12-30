module KeyboardAvoidingViewExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (button, keyboardAvoidingView, str, text, textInput, touchableWithoutFeedback, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (behavior, placeholder, style, title)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | DismissKeyboard


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DismissKeyboard ->
            ( model, Task.perform (always NoOp) <| Keyboard.dismiss )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            }
        , inner =
            { padding = 24
            , flex = 1
            , justifyContent = "space-around"
            }
        , header =
            { fontSize = 36
            , marginBottom = 48
            }
        , textInput =
            { height = 40
            , borderColor = "#000000"
            , borderBottomWidth = 1
            , marginBottom = 36
            }
        , btnContainer =
            { backgroundColor = "white"
            , marginTop = 12
            }
        }


root : Model -> Html Msg
root model =
    keyboardAvoidingView
        [ behavior <|
            case Platform.os of
                "ios" ->
                    "padding"

                _ ->
                    "height"
        , style styles.container
        ]
        [ touchableWithoutFeedback [ onPress <| Decode.succeed DismissKeyboard ]
            [ view
                [ style styles.inner ]
                [ text [ style styles.header ] [ str "Header" ]
                , textInput [ placeholder "Username", style styles.textInput ] []
                , view
                    [ style styles.btnContainer ]
                    [ button [ title "Submit", onPress <| Decode.succeed NoOp ] [] ]
                ]
            ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
