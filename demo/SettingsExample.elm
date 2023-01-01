module SettingsExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, str, text, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style, title)
import ReactNative.Settings as Settings
import ReactNative.StyleSheet as StyleSheet
import Task exposing (Task)



-- MODEL


type alias Model =
    { data : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { data = "" }, Task.attempt Load <| Settings.get "data" Decode.string )



-- UPDATE


type Msg
    = NoOp
    | Load (Result Decode.Error String)
    | Store String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Load (Ok data) ->
            ( { model | data = data }, Cmd.none )

        Store data ->
            ( { model | data = data }, Task.perform (always NoOp) <| Settings.set [ ( "data", Encode.string data ) ] )

        _ ->
            ( model, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            }
        , value =
            { fontSize = 24
            , marginVertical = 12
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ text [] [ str "Stored value:" ]
        , text [] [ str model.data ]
        , button [ title "Store 'React'", onPress <| Decode.succeed <| Store "React" ] []
        , button [ title "Store 'Native'", onPress <| Decode.succeed <| Store "Native" ] []
        ]


subs _ =
    Sub.map (Load << Ok) <| Settings.watchKey "data" Decode.string


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
