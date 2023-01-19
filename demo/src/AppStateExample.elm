module AppStateExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (str, text, view)
import ReactNative.AppState as AppState exposing (AppState(..))
import ReactNative.Properties exposing (style)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { appState : AppState }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { appState = Active }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | AppStateChanged AppState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AppStateChanged newState ->
            let
                _ =
                    Debug.log "AppStateChangedFrom" model.appState

                _ =
                    Debug.log "To" newState
            in
            ( { model | appState = newState }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            }
        }


showAppState : AppState -> String
showAppState state =
    case state of
        Active ->
            "active"

        Background ->
            "background"

        Inactive ->
            "inactive"


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ text [] [ str <| "Current state is: " ++ showAppState model.appState ]
        ]


subs _ =
    AppState.onChange AppStateChanged


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
