module ActivityIndicatorExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (activityIndicator, str, text, view)
import ReactNative.Properties exposing (color, size, style)
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
            { flex = 1
            , justifyContent = "center"
            }
        , horizontal =
            { flexDirection = "row"
            , justifyContent = "space-around"
            , padding = 10
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container, style styles.horizontal ]
        [ activityIndicator [] []
        , activityIndicator [ size "large" ] []
        , activityIndicator [ size "small", color "#0000ff" ] []
        , activityIndicator [ size "large", color "#00ff00" ] []
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
