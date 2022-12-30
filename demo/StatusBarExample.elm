module StatusBarExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (button, null, safeAreaView, statusBar, str, text, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (animated, backgroundColor, barStyle, hidden, showHideTransition, style, title)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { hidden : Bool
    , statusBarStyle : String
    , statusBarTransition : String
    }


statusBarStyles =
    [ "default", "dark-content", "light-content" ]


statusBarTransitions =
    [ "fade", "slide", "none" ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( { hidden = False, statusBarStyle = "default", statusBarTransition = "fade" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ChangeStatusBarStyle
    | ChangeStatusBarVisibility
    | ChangeStatusBarTransition


getNextItem list current =
    let
        getNextItemHelper xs =
            case xs of
                [] ->
                    Nothing

                x1 :: [] ->
                    if current == x1 then
                        List.head list

                    else
                        Nothing

                x1 :: x2 :: xs1 ->
                    if current == x1 then
                        Just x2

                    else
                        getNextItemHelper (x2 :: xs1)
    in
    list
        |> getNextItemHelper
        |> Maybe.withDefault current


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangeStatusBarStyle ->
            ( { model | statusBarStyle = getNextItem statusBarStyles model.statusBarStyle }, Cmd.none )

        ChangeStatusBarVisibility ->
            ( { model | hidden = not model.hidden }, Cmd.none )

        ChangeStatusBarTransition ->
            ( { model | statusBarTransition = getNextItem statusBarTransitions model.statusBarTransition }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , backgroundColor = "#ECF0F1"
            }
        , buttonsContainer =
            { padding = 10
            }
        , textStyle =
            { textAlign = "center"
            , marginBottom = 8
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.container ]
        [ statusBar
            [ animated True
            , backgroundColor "#61dafb"
            , barStyle model.statusBarStyle
            , showHideTransition model.statusBarTransition
            , hidden model.hidden
            ]
            []
        , text [ style styles.textStyle ]
            [ str <|
                if model.hidden then
                    "Hidden"

                else
                    "Visible"
            ]
        , text [ style styles.textStyle ]
            [ str <| "StatusBar Style:\n" ++ model.statusBarStyle ]
        , text [ style styles.textStyle ]
            [ str <| "StatusBar Transition:\n" ++ model.statusBarTransition ]
        , view [ style styles.buttonsContainer ]
            [ button [ title "Toggle StatusBar", onPress <| Decode.succeed ChangeStatusBarVisibility ] []
            , button [ title "Change StatusBar Style", onPress <| Decode.succeed ChangeStatusBarStyle ] []
            , if Platform.os == "ios" then
                button [ title "Change StatusBar Transition", onPress <| Decode.succeed ChangeStatusBarTransition ] []

              else
                null
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
