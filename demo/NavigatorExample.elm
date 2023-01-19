module NavigatorExample exposing (..)

import Browser
import Browser.Navigation as N
import Html exposing (node)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, ionicon, safeAreaView, str, text, view, virtualizedList)
import ReactNative.Events exposing (onClick, onPress, onRefresh)
import ReactNative.Navigation as Nav exposing (screen, stackNavigator, tabNavigator)
import ReactNative.Properties exposing (color, component, name, options, property, screenOptions, size, style, title)
import ReactNative.StyleSheet as StyleSheet


type alias Model =
    { key : N.Key }


type Msg
    = NoOp
    | GotoDetails
    | GotoDetailsAgain


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key }, Cmd.none )


subs _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ key -> init key
        , view =
            \model ->
                { title = ""
                , body = [ root model ]
                }
        , update = update
        , subscriptions = subs
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotoDetails ->
            ( model, Nav.navigate model.key "Details" )

        GotoDetailsAgain ->
            ( model, Nav.push model.key "Details" {} )


homeScreen _ _ =
    view
        [ style { flex = 1, alignItems = "center", justifyContent = "center" } ]
        [ text [] [ str "Home Screen" ]
        , button
            [ title "Go to Details"
            , onPress (Decode.succeed GotoDetails)
            ]
            []
        ]


detailsScreen _ _ =
    view
        [ style { flex = 1, alignItems = "center", justifyContent = "center" } ]
        [ text [] [ str "Details Screen" ]
        , button
            [ title "Go to Details... again"
            , onPress (Decode.succeed GotoDetailsAgain)
            ]
            []
        ]


homeTabScreen _ _ =
    stackNavigator "Home"
        []
        [ screen
            [ name "Home"
            , component homeScreen
            , options { title = "Overview" }
            ]
            []
        , screen
            [ name "Details"
            , component detailsScreen
            ]
            []
        ]


settingsTabScreen _ _ =
    view
        [ style
            { flex = 1
            , alignItems = "center"
            , justifyContent = "center"
            }
        ]
        [ text [] [ str "settings tab" ] ]


root model =
    tabNavigator "Tab"
        [ screenOptions
            { headerShown = False
            , tabBarActiveTintColor = "tomato"
            , tabBarInactiveTintColor = "gray"
            }
        ]
        [ screen
            [ name "HomeTab"
            , component homeTabScreen
            , options { tabBarIcon = \p -> ionicon "ios-information-circle" [ color p.color, size p.size ] }
            ]
            []
        , screen
            [ name "SettingsTab"
            , component settingsTabScreen
            , options { tabBarIcon = \p -> ionicon "ios-list" [ color p.color, size p.size ] }
            ]
            []
        ]
