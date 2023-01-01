module LinkingExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import ReactNative exposing (button, str, text, view)
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onPress)
import ReactNative.Linking as Linking
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (style, title)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    { initialURL : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { initialURL = "" }, Task.perform ProcessInitialURL Linking.getInitialURL )



-- UPDATE


type Msg
    = NoOp
    | OpenURL String
    | OpenSettings
    | SendIntent String Value
    | ProcessInitialURL String


unknownURLAlert url =
    Alert.alert ("Don't know how to open this URL: " ++ url) []
        |> Task.map (always ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OpenURL url ->
            ( model
            , url
                |> Linking.canOpenURL
                |> Task.andThen
                    (\can ->
                        if can then
                            url
                                |> Linking.openURL

                        else
                            unknownURLAlert url
                    )
                |> Task.perform (always NoOp)
            )

        OpenSettings ->
            ( model, Task.perform (always NoOp) Linking.openSettings )

        SendIntent action extras ->
            ( model, Task.perform (always NoOp) <| Linking.sendIntent action extras )

        ProcessInitialURL url ->
            ( { model | initialURL = url }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            }
        }


openURLButton url =
    button [ title url, onPress <| Decode.succeed <| OpenURL url ] []


supportedURL =
    "https://google.com"


unsupportedURL =
    "slack://open?team=123456"


openSettingsButton =
    button [ title "Open Settings", onPress <| Decode.succeed OpenSettings ] []


sendIntentButton txt action extras =
    button
        [ title txt
        , onPress <| Decode.succeed (SendIntent action extras)
        ]
        []


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        ([ text [] [ str <| "Initial URL: " ++ model.initialURL ]
         , openURLButton supportedURL
         , openURLButton unsupportedURL
         , openSettingsButton
         ]
            ++ (if Platform.os == "android" then
                    [ sendIntentButton "Power Usage Summary" "android.intent.action.POWER_USAGE_SUMMARY" Encode.null
                    , sendIntentButton "App Notification Settings"
                        "android.settings.APP_NOTIFICATION_SETTINGS"
                        (Encode.list Encode.object
                            [ [ ( "android.provider.extra.APP_PACKAGE", Encode.string "com.facebook.katana" ) ] ]
                        )
                    ]

                else
                    []
               )
        )


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
