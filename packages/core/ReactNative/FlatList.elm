module ReactNative.FlatList exposing (FlatListProps, flatList)

import Html exposing (Attribute, Html, node)
import ReactNative.Properties exposing (ItemLayout, data, getItemLayout, keyExtractor, renderItem)


type alias FlatListProps item withItem msg =
    { data : List item
    , keyExtractor : item -> Int -> String
    , renderItem : { withItem | item : item, index : Int } -> Html msg
    , getItemLayout : Maybe (List item -> Int -> ItemLayout)
    }


flatList : FlatListProps item withItem msg -> List (Attribute msg) -> Html msg
flatList options props =
    node "FlatList"
        ([ data options.data
         , keyExtractor options.keyExtractor
         , renderItem options.renderItem
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
