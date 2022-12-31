module ReactNative.Properties exposing
    ( ItemLayout
    , RippleConfig
    , activeOpacity
    , android_disableSound
    , android_ripple
    , animated
    , animationType
    , backgroundColor
    , barStyle
    , behavior
    , boolValue
    , color
    , component
    , contentContainerStyle
    , data
    , delayLongPress
    , disabled
    , editable
    , encode
    , getId
    , getItem
    , getItemCount
    , getItemLayout
    , hidden
    , horizontal
    , initialNumToRender
    , initialParams
    , initialScrollIndex
    , inverted
    , ios_backgroundColor
    , keyExtractor
    , listKey
    , maxLength
    , maxToRenderPerBatch
    , multiline
    , name
    , numberOfLines
    , onstyle
    , options
    , persistentScrollbar
    , placeholder
    , presentationStyle
    , progressViewOffset
    , property
    , refreshCtrl
    , refreshing
    , removeClippedSubviews
    , renderItem
    , renderScrollComponent
    , renderSectionFooter
    , renderSectionHeader
    , resizeMode
    , sections
    , showHideTransition
    , size
    , source
    , stickySectionHeadersEnabled
    , stringValue
    , style
    , thumbColor
    , title
    , trackColor
    , transparent
    , underlayColor
    , unstable_pressDelay
    , visible
    , windowSize
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


keyExtractor : (a -> Int -> String) -> Attribute msg
keyExtractor =
    property "keyExtractor" << encode


renderItem : (a -> Html msg) -> Attribute msg
renderItem =
    property "renderItem" << encode


renderScrollComponent : (a -> Html msg) -> Attribute msg
renderScrollComponent =
    property "renderScrollComponent" << encode


renderSectionHeader : (a -> Html msg) -> Attribute msg
renderSectionHeader =
    property "renderSectionHeader" << encode


renderSectionFooter : (a -> Html msg) -> Attribute msg
renderSectionFooter =
    property "renderSectionFooter" << encode


contentContainerStyle : a -> Attribute msg
contentContainerStyle =
    property "contentContainerStyle" << encode


boolValue =
    property "value" << Encode.bool


stringValue =
    property "value" << Encode.string


extraData =
    property "extraData" << encode


data =
    property "data" << encode


stickySectionHeadersEnabled =
    property "stickySectionHeadersEnabled" << Encode.bool


removeClippedSubviews =
    property "removeClippedSubviews" << Encode.bool


persistentScrollbar =
    property "persistentScrollbar" << Encode.bool


numberOfLines =
    property "numberOfLines" << Encode.int


progressViewOffset =
    property "progressViewOffset" << Encode.float


activeOpacity =
    property "activeOpacity" << Encode.float


delayLongPress =
    property "delayLongPress" << Encode.int


unstable_pressDelay =
    property "unstable_pressDelay" << Encode.int


type alias RippleConfig =
    { color : String
    , borderless : Bool
    , radius : Float
    , foreground : Bool
    }


android_ripple : RippleConfig -> Attribute msg
android_ripple =
    property "android_ripple" << encode


maxLength =
    property "maxLength" << Encode.int


multiline =
    property "multiline" << Encode.bool


android_disableSound =
    property "android_disableSound" << Encode.bool


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


behavior =
    property "behavior" << Encode.string


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


horizontal =
    property "horizontal" << Encode.bool


inverted =
    property "inverted" << Encode.bool


initialNumToRender =
    property "initialNumToRender" << Encode.int


size =
    property "size" << Encode.int


initialScrollIndex =
    property "initialScrollIndex" << Encode.int


windowSize =
    property "windowSize" << Encode.int


maxToRenderPerBatch =
    property "maxToRenderPerBatch" << Encode.int


listKey =
    property "listKey" << Encode.string


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


underlayColor =
    property "underlayColor" << Encode.string


getItem : (data -> item) -> Attribute msg
getItem fn =
    property "getItem" <| encode fn


getItemCount : (data -> Int) -> Attribute msg
getItemCount fn =
    property "getItemCount" <| encode fn


type alias ItemLayout =
    -- length: ITEM_HEIGHT, offset: ITEM_HEIGHT*index
    { length : Float, offset : Float, index : Int }


getItemLayout : (data -> Int -> ItemLayout) -> Attribute msg
getItemLayout fn =
    property "getItemLayout" <| encode fn


type alias Rect =
    { top : Maybe Float, left : Maybe Float, right : Maybe Float, bottom : Maybe Float }


hitSlop : Rect -> Attribute msg
hitSlop =
    property "hitSlop" << encode


pressRetentionOffset : Rect -> Attribute msg
pressRetentionOffset =
    property "pressRetentionOffset" << encode
