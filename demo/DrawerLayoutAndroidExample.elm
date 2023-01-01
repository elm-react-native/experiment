module DrawerLayoutAndroidExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, drawerLayoutAndroid, str, text, view)
import ReactNative.Alert as Alert
import ReactNative.DrawerLayoutAndroid as Drawer
import ReactNative.Events exposing (onDrawerClose, onDrawerOpen, onPress)
import ReactNative.Properties exposing (drawerPosition, drawerWidth, id, renderNavigationView, style, title)
import ReactNative.StyleSheet as StyleSheet
import Task exposing (Task)



-- MODEL


type alias Model =
    { drawerPosition : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { drawerPosition = "left" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ToggleDrawerPosiiton
    | OpenDrawer
    | CloseDrawer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleDrawerPosiiton ->
            ( { model
                | drawerPosition =
                    if model.drawerPosition == "left" then
                        "right"

                    else
                        "left"
              }
            , Cmd.none
            )

        OpenDrawer ->
            ( model, Task.perform (always NoOp) <| Drawer.open drawerId )

        CloseDrawer ->
            ( model, Task.perform (always NoOp) <| Drawer.close drawerId )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , alignItems = "center"
            , justifyContent = "center"
            , padding = 16
            }
        , navigationContainer =
            { backgroundColor = "#ecf0f1"
            }
        , paragraph =
            { padding = 16
            , fontSize = 15
            , textAlign = "center"
            }
        }


drawerId =
    "TEST_DRAWER"


root : Model -> Html Msg
root model =
    drawerLayoutAndroid
        [ id drawerId
        , drawerWidth 300
        , drawerPosition model.drawerPosition
        , renderNavigationView
            (\_ ->
                view
                    [ style styles.container
                    , style styles.navigationContainer
                    ]
                    [ text [ style styles.paragraph ] [ str "I'm in the Drawer!" ]
                    , button [ title "Close Drawer", onPress <| Decode.succeed CloseDrawer ] []
                    ]
            )
        ]
        [ view [ style styles.container ]
            [ text [ style styles.paragraph ] [ str <| "Drawer on the " ++ model.drawerPosition ++ "!" ]
            , button
                [ title "Change Drawer Position"
                , onPress <| Decode.succeed ToggleDrawerPosiiton
                ]
                []
            , text [ style styles.paragraph ] [ str "Swipe from the side or press button below to see it!" ]
            , button [ title "Open Drawer", onPress <| Decode.succeed OpenDrawer ] []
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
