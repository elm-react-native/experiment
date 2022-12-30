module ReactNative.Properties exposing
    ( animated
    , animationType
    , backgroundColor
    , barStyle
    , boolValue
    , color
    , component
    , contentContainerStyle
    , disabled
    , editable
    , encode
    , getId
    , hidden
    , initialParams
    , ios_backgroundColor
    , keyExtractor
    , maxLength
    , multiline
    , name
    , numberOfLines
    , onstyle
    , options
    , placeholder
    , presentationStyle
    , property
    , refreshCtrl
    , refreshing
    , renderItem
    , renderSectionHeader
    , resizeMode
    , sections
    , showHideTransition
    , source
    , stringValue
    , style
    , thumbColor
    , title
    , trackColor
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


boolValue =
    property "value" << Encode.bool


stringValue =
    property "value" << Encode.string


numberOfLines =
    property "numberOfLines" << Encode.int


maxLength =
    property "maxLength" << Encode.int


multiline =
    property "multiline" << Encode.bool


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


resizeMode =
    property "resizeMode" << Encode.string


animationType =
    property "animationType" << Encode.string


transparent =
    property "transparent" << Encode.bool


editable =
    property "editable" << Encode.bool


animated =
    property "animated" << Encode.bool


showHideTransition =
    property "showHideTransition" << Encode.string


placeholder =
    property "placeholder" << Encode.string


visible =
    property "visible" << Encode.bool


presentationStyle =
    property "presentationStyle" << Encode.string


backgroundColor =
    property "backgroundColor" << Encode.string


barStyle =
    property "barStyle" << Encode.string


trackColor : String -> String -> Attribute msg
trackColor false true =
    property "trackColor" <|
        encode
            { false = false
            , true = true
            }


thumbColor =
    property "thumbColor" << Encode.string


ios_backgroundColor =
    property "ios_backgroundColor" << Encode.string
