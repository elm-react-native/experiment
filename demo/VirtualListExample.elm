module VirtualListExample exposing (..)

import Browser
import Debug
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (safeAreaView, str, text, view, virtualizedList)
import ReactNative.Events exposing (onClick, onPress, onRefresh)
import ReactNative.Properties exposing (encode, property, style)
import ReactNative.StyleSheet as StyleSheet


type alias Model =
    String


type Msg
    = NoOp


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


init () =
    ( "", Cmd.none )


update msg model =
    ( model, Cmd.none )


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
        [ text [ style styles.title ] [ str title ] ]


root model =
    safeAreaView [ style styles.container ]
        [ virtualizedList
            [ property "renderItem" <|
                encode
                    (\{ item } -> itemView item.title)

            --, property "keyExtractor" <| encode (\item -> item.key)
            , property "data" <| encode []
            , property "getItemCount" <| encode (\_ -> 50)
            , property "getItem" <| encode (\_ index -> { key = index, title = "Item2 " ++ String.fromInt index })
            ]
            []
        ]
