module DimensionsExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (fragment, str, text, view)
import ReactNative.Dimensions as Dimensions
    exposing
        ( DimensionsValue
        , ScaledSize
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


scaledSizeView : String -> ScaledSize -> Html msg
scaledSizeView title metrics =
    fragment
        []
        [ text [ style styles.header ] [ str title ]
        , text [] [ str <| "width - " ++ String.fromFloat metrics.width ]
        , text [] [ str <| "height - " ++ String.fromFloat metrics.height ]
        , text [] [ str <| "scale - " ++ String.fromFloat metrics.scale ]
        , text [] [ str <| "font Scale - " ++ String.fromFloat metrics.fontScale ]
        ]


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ scaledSizeView "Window Dimensions" model.window
        , scaledSizeView "Screen Dimensions" model.screen
        ]


subs _ =
    Dimensions.onChange <| Decode.map DimensionsValueChanged dimensionsValueDecoder


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
