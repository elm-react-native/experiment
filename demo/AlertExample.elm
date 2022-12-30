module AlertExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import ReactNative exposing (button, view)
import ReactNative.Alert as Alert exposing (alert, withButtons, withMessage, withOptions)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style, title)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ShowAlert
    | DismissAlert
    | CancelPressed


showAlert =
    Alert.show (Maybe.withDefault NoOp)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ShowAlert ->
            ( model
            , alert "Alert title"
                |> withMessage "My Alert Msg"
                |> withButtons
                    [ { text = "Cancel"
                      , onPress = Just CancelPressed
                      , style = "cancel"
                      }
                    ]
                |> withOptions True "light" (Just DismissAlert)
                |> showAlert
            )

        CancelPressed ->
            ( model
            , showAlert <| alert "Cancel Pressed"
            )

        DismissAlert ->
            ( model
            , showAlert <| alert "This alert was dismissed by tapping outside of the alert dialog."
            )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ button [ title "Show alert", onPress <| Decode.succeed ShowAlert ] []
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
