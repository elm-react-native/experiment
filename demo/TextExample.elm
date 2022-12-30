module TextExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (safeAreaView, str, text, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (numberOfLines, style)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { title : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { title = "Bird's Nest" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | PressTitle


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PressTitle ->
            ( { model | title = "Bird's Nest [pressed]" }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { baseText =
            { fontFamily = "Cochin"
            , fontWeight = "bold"
            }
        , titleText =
            { fontSize = 20
            , fontWeight = "bold"
            }
        , innerText = { color = "red" }
        }


root : Model -> Html Msg
root model =
    safeAreaView []
        [ text
            [ style styles.baseText ]
            [ text
                [ style styles.titleText
                , onPress (Decode.succeed PressTitle)
                ]
                [ str <| model.title ++ "\n\n" ]
            , text [ numberOfLines 5 ] [ str "This is not really a bird nest.\n" ]
            , text [ style styles.baseText ]
                [ str "I am bold"
                , text [ style styles.innerText ] [ str " and red" ]
                ]
            ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
