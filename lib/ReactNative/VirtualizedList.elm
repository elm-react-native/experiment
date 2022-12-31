module ReactNative.VirtualizedList exposing (VirtualizedListProps, fixedLength, virtualizedList)

import Html exposing (Attribute, Html, node)
import ReactNative.Properties exposing (ItemLayout, data, getItem, getItemCount, getItemLayout, keyExtractor, renderItem)


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
