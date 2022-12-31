module VirtualizedListExample exposing (..)

import Browser
import Debug
import Json.Decode as Decode
import Json.Encode as Encode
import Process
import ReactNative exposing (refreshControl, safeAreaView, str, text, view, virtualizedList)
import ReactNative.Events exposing (onClick, onPress, onRefresh)
import ReactNative.Properties exposing (encode, property, refreshCtrl, refreshing, style)
import ReactNative.StyleSheet as StyleSheet
import ReactNative.VirtualizedList exposing (fixedLength)
import Task


type alias Model =
    { size : Int, refreshing : Bool }


type Msg
    = NoOp
    | IncreaseSize
    | Refresh


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
    ( { size = 500, refreshing = False }, Cmd.none )


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Refresh ->
            ( { model | refreshing = True }
            , Task.perform (\_ -> IncreaseSize) <| Process.sleep 2000
            )

        IncreaseSize ->
            ( { model | size = model.size + 50, refreshing = False }, Cmd.none )


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
    let
        ridx i =
            model.size - i - 1
    in
    safeAreaView [ style styles.container ]
        [ virtualizedList
            { renderItem = \{ item } -> itemView item.title
            , keyExtractor = \item _ -> item.id
            , data = ()
            , getItemCount = always model.size
            , getItem =
                \_ index ->
                    let
                        id =
                            String.fromInt (index + 1)
                    in
                    { id = id, title = "Item " ++ id }
            , getItemLayout = Just <| \_ index -> fixedLength 166 index
            }
            [ refreshing model.refreshing
            , onRefresh <| Decode.succeed Refresh
            ]
        ]
