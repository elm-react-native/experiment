module PixelRatioExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (image, safeAreaView, str, text, view)
import ReactNative.PixelRatio as PixelRatio
import ReactNative.Properties exposing (source, style)
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


size =
    50.0


cat =
    { uri = "https://reactnative.dev/docs/assets/p_cat1.png"
    , width = size
    , height = size
    }


styles =
    StyleSheet.create
        { scrollContainer =
            { flex = 1
            }
        , container =
            { justifyContent = "center"
            , alignItems = "center"
            }
        , value =
            { fontSize = 24
            , marginBottom = 12
            , marginTop = 4
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.scrollContainer ]
        [ view [ style styles.container ]
            [ text [] [ str "Current Pixel Ratio is:" ]
            , text [] [ str <| String.fromFloat <| PixelRatio.get () ]
            ]
        , view [ style styles.container ]
            [ text [] [ str "Current Font Scale is:" ]
            , text [] [ str <| String.fromFloat <| PixelRatio.getFontScale () ]
            ]
        , view [ style styles.container ]
            [ text [] [ str "On this device images with a layout width of" ]
            , text [ style styles.value ] [ str <| String.fromFloat size ++ " px" ]
            , image [ source cat ] []
            ]
        , view [ style styles.container ]
            [ text [] [ str "require images with a pixel width of" ]
            , text [ style styles.value ] [ str <| String.fromFloat (PixelRatio.getPixelSizeForLayoutSize size) ++ " px" ]
            , image
                [ source cat
                , style
                    { width = PixelRatio.getPixelSizeForLayoutSize size
                    , height = PixelRatio.getPixelSizeForLayoutSize size
                    }
                ]
                []
            ]
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
