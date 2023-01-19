module PanResponderExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, safeAreaView, view)
import ReactNative.Animated as Animated exposing (AnimationResult)
import ReactNative.Easing as Easing
import ReactNative.Events exposing (onPress)
import ReactNative.PanResponder as PanResponder
import ReactNative.Properties exposing (style, title)
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
    | PanResponderRelease


pan =
    Animated.createXY 0 0


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PanResponderRelease ->
            ( model
              --, Cmd.none
            , pan
                |> Animated.spring { toValue = { x = 0, y = 0 }, easing = Easing.bounce }
                |> Animated.start
                |> Task.perform (always NoOp)
            )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            }
        , box =
            { backgroundColor = "#61dafb"
            , width = 80
            , height = 80
            , borderRadius = 4
            }
        }


root : Model -> Html Msg
root model =
    view
        [ style styles.container ]
        [ Animated.view
            [ style styles.box
            , style <| Animated.getLayout pan
            , PanResponder.prop <|
                PanResponder.create
                    [ PanResponder.onStartShouldSetPanResponder <|
                        Decode.succeed True
                    , PanResponder.onPanResponderMove <|
                        Animated.event2 () (Animated.mapping (\x y -> { dx = x, dy = y }) pan) (Decode.succeed NoOp)
                    , PanResponder.onPanResponderRelease <| Decode.succeed PanResponderRelease
                    ]
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
        , subscriptions = subs
        }
