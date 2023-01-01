module ReactNative.VirtualizedList exposing
    ( VirtualizedListProps
    , fixedLength
    , flashScrollIndicators
    , getChildContext
    , getScrollRef
    , getScrollResponder
    , getScrollableNode
    , hasMore
    , recordInteraction
    , scrollToEnd
    , scrollToIndex
    , scrollToItem
    , scrollToOffset
    , setNativeProps
    , virtualizedList
    )

import Html exposing (Attribute, Html, node)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import ReactNative.Properties exposing (ItemLayout, data, getItem, getItemCount, getItemLayout, keyExtractor, renderItem)
import Task exposing (Task)


type alias VirtualizedListProps data item withItem msg =
    { data : data
    , keyExtractor : item -> Int -> String
    , renderItem : { withItem | item : item, index : Int } -> Html msg
    , getItem : data -> Int -> item
    , getItemCount : data -> Int
    , getItemLayout : Maybe (data -> Int -> ItemLayout)
    }


fixedLength : Float -> Int -> ItemLayout
fixedLength length index =
    { length = length, offset = length * toFloat index, index = index }


virtualizedList : VirtualizedListProps data item withItem msg -> List (Attribute msg) -> Html msg
virtualizedList options props =
    node "VirtualizedList"
        ([ data options.data
         , keyExtractor options.keyExtractor
         , renderItem options.renderItem
         , getItem options.getItem
         , getItemCount options.getItemCount
         ]
            ++ (case options.getItemLayout of
                    Just fn ->
                        [ getItemLayout fn ]

                    _ ->
                        []
               )
            ++ props
        )
        []


flashScrollIndicators : String -> Task Never ()
flashScrollIndicators id =
    Task.succeed ()


getChildContext : String -> Decoder msg -> Task Decode.Error msg
getChildContext id decoder =
    Task.fail <| Decode.Failure "" Encode.null


getScrollableNode : String -> Task Never Float
getScrollableNode id =
    Task.succeed 0


getScrollRef : String -> Task Never ()
getScrollRef id =
    Task.succeed ()


getScrollResponder : String -> Task Never ()
getScrollResponder id =
    Task.succeed ()


hasMore : String -> Task Never Bool
hasMore id =
    Task.succeed False


scrollToEnd : String -> Task Never ()
scrollToEnd id =
    Task.succeed ()


scrollToIndex : String -> Task Never ()
scrollToIndex id =
    Task.succeed ()


scrollToItem : String -> String -> Task Never ()
scrollToItem id target =
    Task.succeed ()


scrollToOffset : String -> Task Never ()
scrollToOffset id =
    Task.succeed ()


recordInteraction : String -> Task Never ()
recordInteraction id =
    Task.succeed ()


setNativeProps : String -> props -> Task Never ()
setNativeProps id props =
    Task.succeed ()
