module ButtonExample exposing (..)

import Browser
import Html.Lazy exposing (lazy)
import Json.Decode as Decode
import Json.Encode as Encode
import Process
import ReactNative exposing (button, image, pressable, require, safeAreaView, str, text, view)
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onClick, onPress, onRefresh)
import ReactNative.Properties exposing (color, disabled, source, style, title)
import ReactNative.StyleSheet as StyleSheet
import Task


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



-- MODEL


type alias Model =
    {}


init () =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | PressSimpleButton
    | PressAdjustedColorButton
    | PressLeftButton
    | PressRightButton


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PressSimpleButton ->
            let
                _ =
                    Debug.log "PressSimpleButton" msg
            in
            ( model, Task.perform (always NoOp) <| Alert.alert "Simple Button pressed" [] )

        PressLeftButton ->
            ( model, Task.perform (always NoOp) <| Alert.alert "Left button pressed" [] )

        PressRightButton ->
            ( model, Task.perform (always NoOp) <| Alert.alert "Right button pressed" [] )

        PressAdjustedColorButton ->
            ( model, Task.perform (always NoOp) <| Alert.alert "Button with adjusted color pressed" [] )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , marginHorizontal = 16
            }
        , title =
            { textAlign = "center"
            , marginVertical = 8
            }
        , fixToText =
            { flexDirection = "row"
            , justifyContent = "space-between"
            }
        , separator =
            { marginVertical = 8
            , borderBottomColor = "#737373"
            , borderBottomWidth = StyleSheet.hairlineWidth
            }
        }


separator =
    view [ style styles.separator ] []


root model =
    safeAreaView [ style styles.container ]
        [ view [] [ text [ style styles.title ] [ str "The title and onPress handler are required. It is recommended to set accessibilityLabel to help make your app usable by everyone." ] ]
        , button [ title "Press me", onPress <| Decode.succeed PressSimpleButton ] []
        , separator
        , view []
            [ text [ style styles.title ] [ str "Adjust the color in a way that looks standard on each platform. On  iOS, the color prop controls the color of the text. On Android, the color adjusts the background color of the button." ]
            , button [ title "Press me", color "#f194ff", onPress <| Decode.succeed PressAdjustedColorButton ] []
            ]
        , separator
        , view []
            [ text [ style styles.title ] [ str "All interaction for the component are disabled." ]
            , button
                [ title "Press me"
                , disabled True
                , color "#f194ff"
                , onPress <| Decode.succeed PressAdjustedColorButton
                ]
                []
            ]
        , separator
        , view []
            [ text [ style styles.title ] [ str "This layout strategy lets the title define the width of the button." ]
            , view [ style styles.fixToText ]
                [ button
                    [ title "Left button"
                    , onPress <| Decode.succeed PressLeftButton
                    ]
                    []
                , button
                    [ title "Right button"
                    , onPress <| Decode.succeed PressRightButton
                    ]
                    []
                ]
            ]
        ]
