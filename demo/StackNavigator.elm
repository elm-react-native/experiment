module StackNavigator exposing (..)

import Browser
import Browser.Navigation as N
import Debug
import Html exposing (node)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, safeAreaView, text, view, virtualizedList)
import ReactNative.Events exposing (onClick, onPress, onRefresh)
import ReactNative.Navigation as Nav
import ReactNative.Navigation.Stack as Stack
import ReactNative.Properties
    exposing
        ( component
        , name
        , onstyle
        , options
        , property
        , style
        , title
        )
import ReactNative.StyleSheet as StyleSheet


type alias Model =
    { key : N.Key }


type Msg
    = NoOp
    | GotoDetails
    | GotoDetailsAgain


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ key -> ( { key = key }, Cmd.none )
        , view =
            \model ->
                { title = ""
                , body = [ root model ]
                }
        , update =
            \msg model ->
                case msg of
                    NoOp ->
                        ( model, Cmd.none )

                    GotoDetails ->
                        ( model, Nav.navigate model.key "Details" )

                    GotoDetailsAgain ->
                        ( model, Nav.push model.key "Details" )
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }


homeScreen () =
    view
        [ style { flex = 1, alignItems = "center", justifyContent = "center" } ]
        [ text [] "Home Screen"
        , button
            [ title "Go to Details"
            , onPress (Decode.succeed GotoDetails)
            ]
            []
        ]


detailsScreen () =
    view
        [ style { flex = 1, alignItems = "center", justifyContent = "center" } ]
        [ text [] "Details Screen"
        , button
            [ title "Go to Details... again"
            , onPress (Decode.succeed GotoDetailsAgain)
            ]
            []
        ]


root model =
    Stack.navigator
        []
        [ Stack.screen
            [ name "Home"
            , component homeScreen
            , options { title = "Overview" }
            ]
            []
        , Stack.screen
            [ name "Details"
            , component detailsScreen
            ]
            []
        ]
