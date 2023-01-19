module ActionSheetIOSExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Random
import ReactNative exposing (button, str, text, view)
import ReactNative.ActionSheetIOS as ActionSheetIOS
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style, title)
import ReactNative.StyleSheet as StyleSheet
import Task exposing (Task)



-- MODEL


type alias Model =
    { result : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { result = "🔮" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ShowActionSheet
    | DoAction Int
    | NewNumber Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ShowActionSheet ->
            ( model
            , ActionSheetIOS.show
                [ "Cancel", "Generate number", "Reset" ]
                [ ActionSheetIOS.destructiveButtonIndex 2
                , ActionSheetIOS.cancelButtonIndex 0
                , ActionSheetIOS.userInterfaceStyle "dark"
                ]
                |> Task.perform DoAction
            )

        DoAction 0 ->
            ( model, Alert.showAlert (always NoOp) "Cancel" [] )

        DoAction 1 ->
            ( model, Random.generate NewNumber (Random.int 1 100) )

        NewNumber n ->
            ( { model | result = String.fromInt n }, Cmd.none )

        DoAction _ ->
            ( { model | result = "🔮" }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            }
        , result =
            { fontSize = 64
            , textAlign = "center"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ text [ style styles.result ] [ str model.result ]
        , button
            [ onPress <| Decode.succeed ShowActionSheet
            , title "Show Action Sheet"
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
