module SwitchExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (switch, view)
import ReactNative.Events exposing (onValueChange)
import ReactNative.Properties exposing (boolValue, ios_backgroundColor, style, thumbColor, trackColor)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { isEnabled : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { isEnabled = False }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | SetIsEnabled Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetIsEnabled b ->
            ( { model | isEnabled = b }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , alignItems = "center"
            , justifyContent = "center"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ switch
            [ trackColor "#767577" "#81b0ff"
            , thumbColor <|
                if model.isEnabled then
                    "#f5dd4b"

                else
                    "#f4f3f4"
            , ios_backgroundColor "#3e3e3e"
            , onValueChange SetIsEnabled
            , boolValue model.isEnabled
            ]
            []
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
