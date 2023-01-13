module BackHandlerExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (str, text, view)
import ReactNative.Alert as Alert
import ReactNative.BackHandler as BackHandler
import ReactNative.Properties exposing (style)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | HardwareBackPressed
    | AlertMsg Alert.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HardwareBackPressed ->
            ( model
            , Alert.showAlert AlertMsg
                "Hold on!"
                [ Alert.message "Are you sure you want to go back?"
                , Alert.buttons [ "Cancel", "YES" ]
                ]
            )

        AlertMsg (Alert.Positive _) ->
            ( model, BackHandler.exitApp )

        _ ->
            ( model, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , alignItems = "center"
            , justifyContent = "center"
            }
        , text =
            { fontSize = 18
            , fontWeight = "bold"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ text [ style styles.text ] [ str "Click Back button!" ] ]


subs _ =
    BackHandler.onHardwareBackPress HardwareBackPressed


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
