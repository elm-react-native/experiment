module DimensionsExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (fragment, text, view)
import ReactNative.Dimensions as Dimensions
    exposing
        ( DimensionsValue
        , DisplayMetrics
        , dimensionsValueDecoder
        , initialDimensionsValue
        )
import ReactNative.Properties exposing (style)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    DimensionsValue


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialDimensionsValue
    , Task.map2 (\screen window -> { screen = screen, window = window })
        Dimensions.getScreen
        Dimensions.getWindow
        |> Task.perform DimensionsValueChanged
    )



-- UPDATE


type Msg
    = NoOp
    | DimensionsValueChanged DimensionsValue


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DimensionsValueChanged value ->
            ( value, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            }
        , header =
            { fontSize = 16
            , marginVertical = 10
            }
        }


displayMetricsView : String -> DisplayMetrics -> Html msg
displayMetricsView title metrics =
    fragment
        []
        [ text [ style styles.header ] title
        , text [] <| "width - " ++ String.fromFloat metrics.width
        , text [] <| "height - " ++ String.fromFloat metrics.height
        , text [] <| "scale - " ++ String.fromFloat metrics.scale
        , text [] <| "font Scale - " ++ String.fromFloat metrics.fontScale
        ]


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ displayMetricsView "Window Dimensions" model.window
        , displayMetricsView "Screen Dimensions" model.screen
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Dimensions.onChange <| Decode.map DimensionsValueChanged dimensionsValueDecoder
        }
