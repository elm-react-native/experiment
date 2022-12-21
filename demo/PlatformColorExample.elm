module PlatformColorExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (text, view)
import ReactNative.Platform as Platform
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { label =
            StyleSheet.compose { padding = 16 } <|
                Platform.select
                    { ios =
                        { color = Platform.color "label"
                        , backgroundColor = Platform.color "systemTealColor"
                        }
                    , android =
                        { color = Platform.color "?android:attr/textColor"
                        , backgroundColor = Platform.color "@android:color/holo_blue_bright"
                        }
                    , default = { color = "black" }
                    }
        , container =
            { flex = 1
            , alignItems = "center"
            , justifyContent = "center"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ text [ style styles.label ] "I am a special label color!" ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
