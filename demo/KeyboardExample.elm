module KeyboardExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (str, text, textInput, view)
import ReactNative.Events exposing (onSubmitEditing)
import ReactNative.Keyboard as Keyboard
import ReactNative.Properties exposing (placeholder, style)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    { keyboardStatus : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { keyboardStatus = "" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | SubmitEditing
    | KeyboardDidShow
    | KeyboardDidHide


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SubmitEditing ->
            ( model, Task.perform (always NoOp) Keyboard.dismiss )

        KeyboardDidShow ->
            ( { model | keyboardStatus = "Keyboard Shown" }, Cmd.none )

        KeyboardDidHide ->
            ( { model | keyboardStatus = "Keyboard Hidden" }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , padding = 36
            }
        , input =
            { padding = 10
            , borderWidth = 0.5
            , borderRadius = 4
            }
        , status =
            { padding = 10
            , textAlign = "center"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ textInput
            [ style styles.input
            , placeholder "Click here..."
            , onSubmitEditing <| Decode.succeed SubmitEditing
            ]
            []
        , text [ style styles.status ] [ str model.keyboardStatus ]
        ]


subs =
    Sub.batch
        [ Keyboard.onDidShow <| Decode.succeed KeyboardDidShow
        , Keyboard.onDidHide <| Decode.succeed KeyboardDidHide
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> subs
        }
