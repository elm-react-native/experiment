module AnimationExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, safeAreaView, view)
import ReactNative.Animated as Animated exposing (AnimationResult)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style, title)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    { fadeAnim : Animated.Value }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { fadeAnim = Animated.create 0 }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | FadeIn
    | FadeOut
    | FadeInCallback AnimationResult
    | FadeOutCallback AnimationResult


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FadeInCallback result ->
            let
                _ =
                    Debug.log "FadeInCallback" result
            in
            ( model, Cmd.none )

        FadeIn ->
            ( model
            , model.fadeAnim
                |> Animated.timing { toValue = 1, duration = 5000 }
                |> Animated.start
                |> Task.perform FadeInCallback
            )

        FadeOutCallback result ->
            let
                _ =
                    Debug.log "FadeOutCallback" result
            in
            ( model, Cmd.none )

        FadeOut ->
            ( model
            , model.fadeAnim
                |> Animated.timing { defaultTimingConfig | toValue = 0, duration = 3000 }
                |> Animated.start
                |> Task.perform FadeOutCallback
            )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , alignItems = "center"
            , justifyContent = "center"
            }
        , fadingContainer =
            { padding = 20
            , backgroundColor = "powderblue"
            }
        , fadingText =
            { fontSize = 28
            }
        , buttonRow =
            { flexBasis = 100
            , justifyContent = "space-evenly"
            , marginVertical = 16
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.container ]
        [ Animated.view [ style styles.fadingContainer, style { opacity = model.fadeAnim } ] []
        , view [ style styles.buttonRow ]
            [ button [ title "Fade In View", onPress <| Decode.succeed FadeIn ] []
            , button [ title "Fade Out View", onPress <| Decode.succeed FadeOut ] []
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
