module VirtualList exposing (..)

import Browser
import Debug
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (safeAreaView, text, view, virtualizedList)
import ReactNative.Events exposing (onClick, onPress, onRefresh)
import ReactNative.Properties exposing (onstyle, property, record, style)
import ReactNative.StyleSheet as StyleSheet


type alias Model =
    String


type Msg
    = NoOp


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( "", Cmd.none )
        , view = \_ -> root
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


styles =
    StyleSheet.create
        { container =
            { flex = 1
            }
        , item =
            { backgroundColor = "#f9c2ff"
            , height = 150
            , justifyContent = "center"
            , marginVertical = 8
            , marginHorizontal = 16
            , padding = 20
            }
        , title = { fontSize = 32 }
        }


itemView title =
    view
        [ style styles.item ]
        [ text [ style styles.title ] title ]


root =
    safeAreaView [ style styles.container ]
        [ virtualizedList
            [ property "renderItem" <|
                record
                    (\{ item } -> itemView item.title)

            --, property "keyExtractor" <| record (\item -> item.key)
            , property "data" <| record []
            , property "getItemCount" <| record (\_ -> 50)
            , property "getItem" <| record (\_ index -> { key = index, title = "Item2 " ++ String.fromInt index })
            ]
            []
        ]
