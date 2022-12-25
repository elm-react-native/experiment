module VibrationExample exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, safeAreaView, text, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (style, title)
import ReactNative.StyleSheet as StyleSheet
import ReactNative.Vibrate as Vibrate



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init () =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | VibrateOnce
    | VibrateWithPattern (List Int)
    | StopVibration


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        VibrateOnce ->
            ( model, Vibrate.once )

        VibrateWithPattern pattern ->
            ( model, Vibrate.pattern pattern )

        StopVibration ->
            ( model, Vibrate.cancel )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , paddingTop = 44
            , padding = 8
            }
        , header =
            { fontSize = 18
            , fontWeight = "bold"
            , textAlign = "center"
            }
        , paragraph =
            { margin = 24
            , textAlign = "center"
            }
        , separator =
            Platform.select
                { ios =
                    {}
                , android =
                    { marginVertical = 8
                    , borderBottomColor = "#737373"
                    , borderBottomWidth = StyleSheet.hairlineWidth
                    }
                }
        }


separator =
    view [ style styles.separator ] []


patternDesc =
    if Platform.os == "android" then
        "wait 1s, vibrate 2s, wait 3s"

    else
        "wait 1s, vibrate, wait 2s, vibrate, wait 3s"


root : Model -> Html Msg
root model =
    safeAreaView
        [ style styles.container ]
        [ text [ style styles.header, style styles.paragraph ] "Vibration API"
        , view []
            [ button
                [ title "Vibrate once"
                , onPress <| Decode.succeed VibrateOnce
                ]
                []
            ]
        , separator
        , text [ style styles.paragraph ] <| "Pattern: " ++ patternDesc
        , button
            [ title "Vibrate with pattern until cancelled"
            , onPress <| Decode.succeed <| VibrateWithPattern [ 1000, 2000, 3000 ]
            ]
            []
        , separator
        , button [ title "Stop vibration pattern", onPress <| Decode.succeed StopVibration, style { color = "#FF0000" } ] []
        ]


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = \model -> { title = "", body = [ root model ] }
        , update = update
        , subscriptions = \_ -> Sub.none
        }
