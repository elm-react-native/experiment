module ToastAndroidExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, safeAreaView, str, text, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style, title)
import ReactNative.StatusBar as StatusBar
import ReactNative.StyleSheet as StyleSheet
import ReactNative.ToastAndroid as Toast
import Task exposing (Task)



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ShowToast String
    | ShowToastWithGravity String Toast.Gravity
    | ShowToastWithGravityAndOffset String Toast.Gravity Float Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ShowToast message ->
            ( model, Task.perform (always NoOp) <| Toast.show message Toast.durationShort )

        ShowToastWithGravity message gravity ->
            ( model, Task.perform (always NoOp) <| Toast.showWithGravity message Toast.durationShort gravity )

        ShowToastWithGravityAndOffset message gravity xOffset yOffset ->
            ( model, Task.perform (always NoOp) <| Toast.showWithGravityAndOffset message Toast.durationLong gravity xOffset yOffset )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , paddingTop = StatusBar.currentHeight
            , backgroundColor = "#888888"
            , padding = 8
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ button
            [ title "Show Toast"
            , onPress <| Decode.succeed <| ShowToast "Example"
            ]
            []
        , button
            [ title "Show Toast gravity TOP"
            , onPress <| Decode.succeed <| ShowToastWithGravity "Example" Toast.Top
            ]
            []
        , button
            [ title "Show Toast gravity CENTER"
            , onPress <| Decode.succeed <| ShowToastWithGravity "Example" Toast.Center
            ]
            []
        , button
            [ title "Show Toast gravity BOTTOM"
            , onPress <| Decode.succeed <| ShowToastWithGravity "Example" Toast.Bottom
            ]
            []
        , button
            [ title "Show Toast gravity and offset"
            , onPress <| Decode.succeed <| ShowToastWithGravityAndOffset "Example" Toast.Bottom 10 10
            ]
            []
        ]


subs _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
