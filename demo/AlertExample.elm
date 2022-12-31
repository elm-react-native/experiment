module AlertExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import ReactNative exposing (button, view)
import ReactNative.Alert as Alert exposing (alert, cancelButton, destructiveButton, okButton, withButtons, withMessage, withOptions)
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
    | TwoButtonAlert
    | ThreeButtonAlert
    | DismissAlert
    | CancelPressed
    | OkPressed
    | AskMeLaterPressed


showAlert =
    Alert.show (Maybe.withDefault NoOp)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TwoButtonAlert ->
            ( model
            , alert "Alert Title"
                |> withMessage "My Alert Msg"
                |> withButtons
                    [ cancelButton "Cancel" <| Just CancelPressed
                    , okButton "OK" <| Just OkPressed
                    ]
                |> showAlert
            )

        ThreeButtonAlert ->
            ( model
            , alert "Alert Title"
                |> withMessage "My Alert Msg"
                |> withButtons
                    [ destructiveButton "Ask me later" <| Just AskMeLaterPressed
                    , cancelButton "Cancel" <| Just CancelPressed
                    , okButton "OK" <| Just OkPressed
                    ]
                |> showAlert
            )

        ShowAlert ->
            ( model
            , alert "Alert title"
                |> withMessage "My Alert Msg"
                |> withButtons [ cancelButton "Cancel" <| Just CancelPressed ]
                |> withOptions True "light" (Just DismissAlert)
                |> showAlert
            )

        AskMeLaterPressed ->
            ( model
            , showAlert <| alert "Ask me later pressed"
            )

        CancelPressed ->
            ( model
            , showAlert <| alert "Cancel Pressed"
            )

        OkPressed ->
            ( model
            , showAlert <| alert "OK Pressed"
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
        [ button [ title "2-Button Alert", onPress <| Decode.succeed TwoButtonAlert ] []
        , button [ title "3-Button Alert", onPress <| Decode.succeed ThreeButtonAlert ] []
        , button [ title "Show alert", onPress <| Decode.succeed ShowAlert ] []
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
