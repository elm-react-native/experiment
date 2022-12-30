module RefreshControlExample exposing (..)

import Browser
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode
import Process
import ReactNative exposing (refreshControl, safeAreaView, scrollView, str, text, view)
import ReactNative.Events exposing (onRefresh)
import ReactNative.Properties exposing (contentContainerStyle, refreshCtrl, refreshing, style, title)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    { refreshing : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { refreshing = False }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | RefreshEnd
    | Refresh


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "update" msg
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RefreshEnd ->
            ( { model | refreshing = False }, Cmd.none )

        Refresh ->
            ( { model | refreshing = True }
            , Task.perform (\_ -> RefreshEnd) <| Process.sleep 2000
            )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            }
        , scrollView =
            { flex = 1
            , backgroundColor = "pink"
            , alignItems = "center"
            , justifyContent = "center"
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.container ]
        [ scrollView
            [ contentContainerStyle styles.scrollView
            , refreshCtrl <|
                refreshControl
                    [ onRefresh (Decode.succeed Refresh)
                    , refreshing model.refreshing
                    ]
            ]
            [ text [] [ str "Pull down to see RefreshControl indicator" ] ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
