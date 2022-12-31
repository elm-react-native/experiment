module ReactNative.SectionList exposing (Section, SectionListProps, sectionList)

import Html exposing (Attribute, Html, node)
import ReactNative.Properties
    exposing
        ( keyExtractor
        , renderItem
        , renderSectionFooter
        , renderSectionHeader
        , sections
        )


type alias Section section item =
    { section | data : List item }


type alias SectionListProps section item msg withItem withSection =
    { sections : List (Section section item)
    , keyExtractor : item -> Int -> String
    , renderItem : { withItem | item : item } -> Html msg
    , renderSectionHeader : { withSection | section : Section section item } -> Html msg
    , renderSectionFooter : { withSection | section : Section section item } -> Html msg
    }


sectionList : SectionListProps section item msg renderItem renderSection -> List (Attribute msg) -> Html msg
sectionList options props =
    node "SectionList"
        ([ sections options.sections
         , keyExtractor options.keyExtractor
         , renderItem options.renderItem
         , renderSectionHeader options.renderSectionHeader
         , renderSectionFooter options.renderSectionFooter
         ]
            ++ props
        )
        []
