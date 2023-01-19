module ShareExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (button, view)
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style, title)
import ReactNative.Share as Share exposing (Action(..))
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
    | Share


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Share ->
            ( model
            , Share.share [ Share.message "React Native | A framework for building native apps using React" ]
                |> Task.andThen
                    (\{ action, activityType } ->
                        Task.mapError (always "") <|
                            case action of
                                SharedAction ->
                                    Alert.alert ("shared with " ++ activityType) []

                                DismissedAction ->
                                    Alert.alert "share dismissed" []
                    )
                |> Task.onError (\err -> Alert.alert ("Error: " ++ err) [])
                |> Task.perform (always NoOp)
            )



-- VIEW


root : Model -> Html Msg
root model =
    view [ style { marginTop = 50 } ]
        [ button
            [ title "Share"
            , onPress <| Decode.succeed Share
            ]
            []
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
