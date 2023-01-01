module AlertExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import ReactNative exposing (button, view)
import ReactNative.Alert as Alert
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
    | AlertMsg Alert.Msg


showAlert =
    Alert.showAlert AlertMsg


showAlertAndIgnore =
    Alert.showAlert (always NoOp)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TwoButtonAlert ->
            ( model
            , showAlert "Alert Title"
                [ Alert.message "My Alert Msg"
                , Alert.buttons_titles [ "Cancel", "OK" ]
                ]
            )

        ThreeButtonAlert ->
            ( model
            , showAlert "Alert Title"
                [ Alert.message "My Alert Msg"
                , Alert.buttons_titles [ "Ask me later", "Cancel", "OK" ]
                ]
            )

        ShowAlert ->
            ( model
            , showAlert "Alert title"
                [ Alert.message "My Alert Msg"
                , Alert.buttons
                    [ Alert.ok "OK"
                    , Alert.destructive "DELETE"
                    ]
                , Alert.cancelable True
                , Alert.userInterfaceStyle "light"
                ]
            )

        AlertMsg alertMsg ->
            ( model
            , case alertMsg of
                Alert.Neutral _ ->
                    showAlertAndIgnore "Ask me later pressed" []

                Alert.Positive _ ->
                    showAlertAndIgnore "OK Pressed" []

                Alert.Negative _ ->
                    showAlertAndIgnore "Cancel Pressed" []

                Alert.Destructive _ ->
                    showAlertAndIgnore "Delete Pressed" []

                Alert.Dismiss ->
                    showAlertAndIgnore "The alert was dismissed by tapping outside of the alert dialog." []

                _ ->
                    Cmd.none
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
