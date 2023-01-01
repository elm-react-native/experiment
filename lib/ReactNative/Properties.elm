module ReactNative.Properties exposing
    ( AccessibilityAction
    , ImageSource
    , ItemLayout
    , RippleConfig
    , accessibilityActions
    , accessibilityElementsHidden
    , accessibilityHint
    , accessibilityIgnoresInvertColors
    , accessibilityLabel
    , accessibilityLanguage
    , accessibilityLiveRegion
    , accessibilityRole
    , accessibilityState
    , accessibilityValue
    , accessibilityViewIsModal
    , accessible
    , activeOpacity
    , android_disableSound
    , android_ripple
    , animated
    , animating
    , animationType
    , backgroundColor
    , barStyle
    , behavior
    , blurRadius
    , boolValue
    , capInsets
    , cellRendererComponent
    , collapsable
    , color
    , colors
    , component
    , contentContainerStyle
    , data
    , defaultSource
    , delayLongPress
    , delayPressIn
    , delayPressOut
    , disableVirtualization
    , disabled
    , drawerBackgroundColor
    , drawerLockMode
    , drawerPosition
    , drawerWidth
    , editable
    , enabled
    , encode
    , fadeDuration
    , focusable
    , getId
    , getItem
    , getItemCount
    , getItemLayout
    , hardwareAccelerated
    , hasTVPreferredFocus
    , hidden
    , hidesWhenStopped
    , hitSlop
    , horizontal
    , id
    , imageStyle
    , importantForAccessibility
    , initialNumToRender
    , initialParams
    , initialScrollIndex
    , inputAccessoryViewID
    , inverted
    , ios_backgroundColor
    , keyExtractor
    , keyboardDismissMode
    , keyboardVerticalOffset
    , listFooterComponent
    , listFooterComponentStyle
    , listHeaderComponent
    , listHeaderComponentStyle
    , listItemComponent
    , listKey
    , loadingIndicatorSource
    , maxLength
    , maxToRenderPerBatch
    , multiline
    , name
    , nativeID
    , needsOffscreenAlphaCompositing
    , nextFocusDown
    , nextFocusForward
    , nextFocusLeft
    , nextFocusRight
    , nextFocusUp
    , numberOfLines
    , onEndReachedThreshold
    , onstyle
    , options
    , persistentScrollbar
    , placeholder
    , pointerEvents
    , presentationStyle
    , progressBackgroundColor
    , progressViewOffset
    , property
    , refreshCtrl
    , refreshing
    , removeClippedSubviews
    , renderItem
    , renderNavigationView
    , renderScrollComponent
    , renderSectionFooter
    , renderSectionHeader
    , renderToHardwareTextureAndroid
    , resizeMode
    , screenOptions
    , sectionSeparatorComponent
    , sections
    , shouldRasterizeIOS
    , showHideTransition
    , size
    , source
    , statusBarBackgroundColor
    , statusBarTranslucent
    , stickySectionHeadersEnabled
    , stringSize
    , stringValue
    , style
    , supportedOrientations
    , testID
    , testOnly_pressed
    , thumbColor
    , tintColor
    , title
    , titleColor
    , touchSoundDisabled
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


imageStyle : a -> Attribute msg
imageStyle =
    property "imageStyle" << encode


sections : a -> Attribute msg
sections =
    property "sections" << encode


blurRadius =
    property "blurRadius" << Encode.int


capInsets : Rect -> Attribute msg
capInsets =
    property "capInsets" << encode


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


id =
    property "id" << Encode.string


statusBarBackgroundColor =
    property "statusBarBackgroundColor" << Encode.string


keyboardDismissMode =
    property "keyboardDismissMode" << Encode.string


keyboardVerticalOffset =
    property "keyboardVerticalOffset" << Encode.float


inputAccessoryViewID =
    property "inputAccessoryViewID" << Encode.string


nativeID =
    property "nativeID" << Encode.string


drawerWidth =
    property "drawerWidth" << Encode.float


drawerPosition =
    property "drawerPosition" << Encode.string


renderNavigationView : (() -> Html msg) -> Attribute msg
renderNavigationView =
    property "renderNavigationView" << encode


extraData =
    property "extraData" << encode


data =
    property "data" << encode


stickySectionHeadersEnabled =
    property "stickySectionHeadersEnabled" << Encode.bool


drawerLockMode =
    property "drawerLockMode" << Encode.string


drawerBackgroundColor =
    property "drawerBackgroundColor" << Encode.string


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


delayPressIn =
    property "delayPressIn" << Encode.int


delayPressOut =
    property "delayPressOut" << Encode.int


cellRendererComponent : (() -> Html msg) -> Attribute msg
cellRendererComponent =
    property "CellRendererComponent" << encode


itemSeparatorComponent : (() -> Html msg) -> Attribute msg
itemSeparatorComponent =
    property "ItemSeparatorComponent" << encode


listItemComponent : (() -> Html msg) -> Attribute msg
listItemComponent =
    property "ListItemComponent" << encode


listEmptyComponent : (() -> Html msg) -> Attribute msg
listEmptyComponent =
    property "ListEmptyComponent" << encode


listFooterComponent : (() -> Html msg) -> Attribute msg
listFooterComponent =
    property "ListFooterComponent" << encode


listFooterComponentStyle =
    property "listFooterComponentStyle" << encode


listHeaderComponent : (() -> Html msg) -> Attribute msg
listHeaderComponent =
    property "ListHeaderComponent" << encode


listHeaderComponentStyle =
    property "listHeaderComponentStyle" << encode


sectionSeparatorComponent : (() -> Html msg) -> Attribute msg
sectionSeparatorComponent =
    property "SectionSeparatorComponent" << encode


enabled =
    property "enabled" << Encode.bool


debug =
    property "debug" << Encode.bool


disableVirtualization =
    property "disableVirtualization" << Encode.bool


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


screenOptions : a -> Attribute msg
screenOptions =
    property "screenOptions" << encode


initialParams : a -> Attribute msg
initialParams =
    property "initialParams" << encode


type alias ImageSource =
    { uri : String
    , width : Float
    , height : Float
    , scale : Float
    , bundle : String
    , method : String
    , headers : List ( String, String )
    , body : String
    , cache : String
    }



--requireSource : String -> Attribute msg
--requireSource s =
--    property "source" <| encode (require s)


source : a -> Attribute msg
source =
    property "source" << encode


defaultSource : a -> Attribute msg
defaultSource =
    property "defaultSource" << encode


loadingIndicatorSource : String -> Attribute msg
loadingIndicatorSource uri =
    property "loadingIndicatorSource" <| encode { uri = uri }


fadeDuration =
    property "fadeDuration" << Encode.int


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


colors =
    property "colors" << Encode.list Encode.string


progressBackgroundColor =
    property "progressBackgroundColor" << Encode.string


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


stringSize =
    property "size" << Encode.string


size =
    property "size" << Encode.int


initialScrollIndex =
    property "initialScrollIndex" << Encode.int


hidesWhenStopped =
    property "hidesWhenStopped" << Encode.bool


animating =
    property "animating" << Encode.bool


windowSize =
    property "windowSize" << Encode.int


maxToRenderPerBatch =
    property "maxToRenderPerBatch" << Encode.int


listKey =
    property "listKey" << Encode.string


presentationStyle =
    property "presentationStyle" << Encode.string


statusBarTranslucent =
    property "statusBarTranslucent" << Encode.bool


supportedOrientations =
    property "supportedOrientations" << Encode.string


backgroundColor =
    property "backgroundColor" << Encode.string


barStyle =
    property "barStyle" << Encode.string


titleColor =
    property "titleColor" << Encode.string


tintColor =
    property "tintColor" << Encode.string


trackColor : String -> String -> Attribute msg
trackColor false true =
    property "trackColor" <|
        encode
            { false = false
            , true = true
            }


updateCellsBatchingPeriod =
    property "updateCellsBatchingPeriod" << Encode.int


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


type alias AccessibilityAction =
    { name : String, label : Maybe String }


accessibilityActions : List AccessibilityAction -> Attribute msg
accessibilityActions =
    property "accessibilityActions" << encode


accessibilityElementsHidden =
    property "accessibilityElementsHidden" << Encode.bool


accessibilityHint =
    property "accessibilityHint" << Encode.string


accessibilityLanguage =
    property "accessibilityLanguage" << Encode.string


accessibilityIgnoresInvertColors =
    property "accessibilityIgnoresInvertColors" << Encode.bool


accessibilityLabel =
    property "accessibilityLabel" << Encode.string


accessibilityLiveRegion =
    property "accessibilityLiveRegion" << Encode.string


accessibilityRole =
    property "accessibilityRole" << Encode.string


{-| TODO: checked
-}
accessibilityState : { disabled : Bool, selected : Bool, checked : String, busy : Bool, expanded : Bool } -> Attribute msg
accessibilityState =
    property "accessibilityState" << encode


accessibilityValue : { min : Float, max : Float, now : Float, text : String } -> Attribute msg
accessibilityValue =
    property "accessibilityValue" << encode


accessibilityViewIsModal =
    property "accessibilityViewIsModal" << Encode.bool


accessible =
    property "accessible" << Encode.bool


collapsable =
    property "collapsable" << Encode.bool


focusable =
    property "focusable" << Encode.bool


touchSoundDisabled =
    property "touchSoundDisabled" << Encode.bool


hasTVPreferredFocus =
    property "hasTVPreferredFocus" << Encode.bool


importantForAccessibility =
    property "importantForAccessibility" << Encode.string


needsOffscreenAlphaCompositing =
    property "needsOffscreenAlphaCompositing" << Encode.bool


nextFocusDown =
    property "nextFocusDown" << Encode.int


nextFocusForward =
    property "nextFocusForward" << Encode.int


onEndReachedThreshold =
    property "onEndReachedThreshold" << Encode.int


nextFocusLeft =
    property "nextFocusLeft" << Encode.int


nextFocusRight =
    property "nextFocusRight" << Encode.int


nextFocusUp =
    property "nextFocusUp" << Encode.int


pointerEvents =
    property "pointerEvents" << Encode.string


renderToHardwareTextureAndroid =
    property "renderToHardwareTextureAndroid" << Encode.bool


hardwareAccelerated =
    property "hardwareAccelerated" << Encode.bool


shouldRasterizeIOS =
    property "shouldRasterizeIOS" << Encode.bool


testID =
    property "testID" << Encode.string


testOnly_pressed =
    property "testOnly_pressed" << Encode.bool
