module ReactNative.Properties exposing
    ( animated
    , animationType
    , backgroundColor
    , barStyle
    , color
    , component
    , contentContainerStyle
    , disabled
    , encode
    , getId
    , hidden
    , initialParams
    , keyExtractor
    , name
    , onstyle
    , options
    , presentationStyle
    , property
    , refreshCtrl
    , refreshing
    , renderItem
    , renderSectionHeader
    , sections
    , showHideTransition
    , source
    , style
    , title
    , transparent
    , visible
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Json.Decode as Decode
import Json.Encode as Encode


property =
    Attr.property


encode : a -> Encode.Value
encode a =
    Encode.string "544d4631-adf8-${a}-4719-b1cc-46843cc90ca4"


style : a -> Attribute msg
style =
    property "style" << encode


sections : a -> Attribute msg
sections =
    property "sections" << encode


keyExtractor : (a -> String) -> Attribute msg
keyExtractor =
    property "keyExtractor" << encode


renderItem : (a -> Html msg) -> Attribute msg
renderItem =
    property "renderItem" << encode


renderSectionHeader : (a -> Html msg) -> Attribute msg
renderSectionHeader =
    property "renderSectionHeader" << encode


contentContainerStyle : a -> Attribute msg
contentContainerStyle =
    property "contentContainerStyle" << encode


options : a -> Attribute msg
options =
    property "options" << encode


initialParams : a -> Attribute msg
initialParams =
    property "initialParams" << encode


source : a -> Attribute msg
source =
    property "source" << encode


onstyle : (a -> List Encode.Value) -> Attribute msg
onstyle =
    style


refreshing =
    property "refreshing" << Encode.bool


hidden =
    property "hidden" << Encode.bool


component : (a -> b -> Html msg) -> Attribute msg
component =
    property "component" << encode


refreshCtrl : Html msg -> Attribute msg
refreshCtrl =
    property "refreshControl" << encode


getId : (p -> String) -> Attribute msg
getId =
    property "getId" << encode


name =
    property "name" << Encode.string


title =
    property "title" << Encode.string


color =
    property "color" << Encode.string


disabled =
    property "disabled" << Encode.bool


animationType =
    property "animationType" << Encode.string


transparent =
    property "transparent" << Encode.bool


animated =
    property "animated" << Encode.bool


showHideTransition =
    property "showHideTransition" << Encode.string


visible =
    property "visible" << Encode.bool


presentationStyle =
    property "presentationStyle" << Encode.string


backgroundColor =
    property "backgroundColor" << Encode.string


barStyle =
    property "barStyle" << Encode.string
