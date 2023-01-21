module ImageExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (image, imageBackground, require, str, text, view)
import ReactNative.Properties exposing (resizeMode, source, style)
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


styles =
    StyleSheet.create
        { container =
            { paddingTop = 50
            , flex = 1
            }
        , tinyLogo =
            { width = 50
            , height = 50
            }
        , logo =
            { width = 66
            , height = 58
            }
        , stretch =
            { width = 50
            , height = 200
            , resizeMode = "stretch"
            }
        , background =
            { flex = 1
            , justifyContent = "center"
            }
        , text =
            { color = "white"
            , fontSize = 42
            , lineHeight = 84
            , fontWeight = "bold"
            , textAlign = "center"
            , backgroundColor = "#000000c0"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ imageBackground
            [ style styles.background
            , source { uri = "https://reactjs.org/logo-og.png" }
            , resizeMode "cover"
            ]
            [ text [ style styles.text ] [ str "Inside" ]
            , image
                [ style styles.tinyLogo
                , source <| require "./assets/icon.png"
                ]
                []
            , image
                [ style styles.tinyLogo
                , source { uri = "https://reactnative.dev/img/tiny_logo.png" }
                ]
                []
            , image
                [ style styles.tinyLogo
                , source { uri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADMAAAAzCAYAAAA6oTAqAAAAEXRFWHRTb2Z0d2FyZQBwbmdjcnVzaEB1SfMAAABQSURBVGje7dSxCQBACARB+2/ab8BEeQNhFi6WSYzYLYudDQYGBgYGBgYGBgYGBgYGBgZmcvDqYGBgmhivGQYGBgYGBgYGBgYGBgYGBgbmQw+P/eMrC5UTVAAAAABJRU5ErkJggg==" }
                ]
                []
            , image
                [ style styles.stretch
                , source <| require "./assets/icon.png"
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
