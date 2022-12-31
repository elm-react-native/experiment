module ScrollViewExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (safeAreaView, scrollView, str, text)
import ReactNative.Properties exposing (style)
import ReactNative.StatusBar as StatusBar
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
            , paddingTop = StatusBar.currentHeight
            }
        , scrollView =
            { backgroundColor = "pink"
            , marginHorizontal = 20
            }
        , text =
            { fontSize = 42
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView
        [ style styles.container ]
        [ scrollView [ style styles.scrollView ]
            [ text [ style styles.text ]
                [ str """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
minim veniam, quis nostrud exercitation ullamco laboris nisi ut
aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.""" ]
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
