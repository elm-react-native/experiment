module ReactNative.Properties exposing
    ( AccessibilityAction
    , ImageSource
    , ItemLayout
    , Rect
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
    , alwaysBounceHorizontal
    , alwaysBounceVertical
    , android_disableSound
    , android_ripple
    , animated
    , animating
    , animationType
    , autoCapitalize
    , autoCorrect
    , automaticallyAdjustContentInsets
    , automaticallyAdjustKeyboardInsets
    , automaticallyAdjustsScrollIndicatorInsets
    , backgroundColor
    , barStyle
    , behavior
    , blurRadius
    , boolValue
    , bounces
    , bouncesZoom
    , canCancelContentTouches
    , capInsets
    , cellRendererComponent
    , centerContent
    , collapsable
    , color
    , colors
    , component
    , componentModel
    , contentContainerStyle
    , contentInset
    , contentInsetAdjustmentBehavior
    , contentOffset
    , data
    , decelerationRateFloat
    , defaultSource
    , delayLongPress
    , delayPressIn
    , delayPressOut
    , directionalLockEnabled
    , disableIntervalMomentum
    , disableScrollViewPanResponder
    , disableVirtualization
    , disabled
    , drawerBackgroundColor
    , drawerLockMode
    , drawerPosition
    , drawerWidth
    , editable
    , enabled
    , encode
    , endFillColor
    , fadeDuration
    , fadingEdgeLength
    , floatValue
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
    , indicatorStyle
    , initialNumToRender
    , initialParams
    , initialScrollIndex
    , inputAccessoryViewID
    , inputMode
    , intValue
    , invertStickyHeaders
    , inverted
    , ios_backgroundColor
    , key
    , keyExtractor
    , keyboardDismissMode
    , keyboardVerticalOffset
    , listFooterComponent
    , listFooterComponentStyle
    , listFooterNode
    , listHeaderComponent
    , listHeaderComponentStyle
    , listHeaderNode
    , listItemComponent
    , listKey
    , loadingIndicatorSource
    , maintainVisibleContentPosition
    , maxLength
    , maxToRenderPerBatch
    , maximumZoomScale
    , minimumZoomScale
    , multiline
    , name
    , nativeID
    , needsOffscreenAlphaCompositing
    , nestedScrollEnabled
    , nextFocusDown
    , nextFocusForward
    , nextFocusLeft
    , nextFocusRight
    , nextFocusUp
    , numberOfLines
    , onEndReachedThreshold
    , onstyle
    , options
    , overScrollMode
    , pagingEnabled
    , persistentScrollbar
    , pinchGestureEnabled
    , placeholder
    , placeholderTextColor
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
    , scrollEnabled
    , scrollEventThrottle
    , sectionSeparatorComponent
    , sections
    , secureTextEntry
    , shadowColor
    , shadowOffset
    , shadowOpacity
    , shadowRadius
    , shouldRasterizeIOS
    , showHideTransition
    , showsHorizontalScrollIndicator
    , showsVerticalScrollIndicator
    , size
    , snapToAlignment
    , snapToEnd
    , snapToInterval
    , snapToOffsets
    , snapToStart
    , source
    , statusBarBackgroundColor
    , statusBarTranslucent
    , stickyHeaderComponent
    , stickyHeaderHiddenOnScroll
    , stickyHeaderIndices
    , stickySectionHeadersEnabled
    , stringSize
    , stringValue
    , style
    , supportedOrientations
    , testID
    , testOnly_pressed
    , textContentType
    , themeVariant
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
    , zoomScale
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
    property "blurRadius" << Encode.float


capInsets : Rect -> Attribute msg
capInsets =
    property "capInsets" << encode


key =
    property "key" << Encode.string


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


intValue =
    property "value" << Encode.int


floatValue =
    property "value" << Encode.float


pinchGestureEnabled =
    property "pinchGestureEnabled" << Encode.bool


scrollEventThrottle =
    property "scrollEventThrottle" << Encode.int


scrollIndicatorInsets : { top : Float, left : Float, right : Float, bottom : Float } -> Attribute msg
scrollIndicatorInsets =
    property "scrollIndicatorInsets" << encode


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


inputMode =
    property "inputMode" << Encode.string


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


contentOffset : Float -> Float -> Attribute msg
contentOffset x y =
    property "contentOffset" <| encode { x = x, y = y }


contentInsetAdjustmentBehavior =
    property "contentInsetAdjustmentBehavior" << Encode.string


contentInset : { top : Float, left : Float, right : Float, bottom : Float } -> Attribute msg
contentInset =
    property "contentInset" << encode


automaticallyAdjustsScrollIndicatorInsets =
    property "automaticallyAdjustsScrollIndicatorInsets" << Encode.bool


automaticallyAdjustKeyboardInsets =
    property "automaticallyAdjustKeyboardInsets" << Encode.bool


automaticallyAdjustContentInsets =
    property "automaticallyAdjustContentInsets" << Encode.bool


alwaysBounceVertical =
    property "alwaysBounceVertical" << Encode.bool


alwaysBounceHorizontal =
    property "alwaysBounceHorizontal" << Encode.bool


bounces =
    property "bounces" << Encode.bool


bouncesZoom =
    property "bouncesZoom" << Encode.bool


canCancelContentTouches =
    property "canCancelContentTouches" << Encode.bool


centerContent =
    property "centerContent" << Encode.bool


decelerationRate =
    property "decelerationRate" << Encode.string


decelerationRateFloat =
    property "decelerationRate" << Encode.float


directionalLockEnabled =
    property "directionalLockEnabled" << Encode.bool


disableIntervalMomentum =
    property "disableIntervalMomentum" << Encode.bool


disableScrollViewPanResponder =
    property "disableScrollViewPanResponder" << Encode.bool


stickySectionHeadersEnabled =
    property "stickySectionHeadersEnabled" << Encode.bool


endFillColor =
    property "endFillColor" << Encode.float


fadingEdgeLength =
    property "fadingEdgeLength" << Encode.float


indicatorStyle =
    property "indicatorStyle" << Encode.string


invertStickyHeaders =
    property "invertStickyHeaders" << Encode.bool


stickyHeaderHiddenOnScroll =
    property "stickyHeaderHiddenOnScroll" << Encode.bool


stickyHeaderIndices =
    property "stickyHeaderIndices" << Encode.list Encode.int


zoomScale =
    property "zoomScale" << Encode.float


drawerLockMode =
    property "drawerLockMode" << Encode.string


drawerBackgroundColor =
    property "drawerBackgroundColor" << Encode.string


removeClippedSubviews =
    property "removeClippedSubviews" << Encode.bool


pagingEnabled =
    property "pagingEnabled" << Encode.bool


persistentScrollbar =
    property "persistentScrollbar" << Encode.bool


scrollEnabled =
    property "scrollEnabled" << Encode.bool


showsHorizontalScrollIndicator =
    property "showsHorizontalScrollIndicator" << Encode.bool


showsVerticalScrollIndicator =
    property "showsVerticalScrollIndicator" << Encode.bool


snapToAlignment =
    property "snapToAlignment" << Encode.bool


snapToEnd =
    property "snapToEnd" << Encode.bool


snapToStart =
    property "snapToStart" << Encode.bool


snapToInterval =
    property "snapToInterval" << Encode.int


snapToOffsets =
    property "snapToOffsets" << Encode.list Encode.int


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


stickyHeaderComponent : (() -> Html msg) -> Attribute msg
stickyHeaderComponent =
    property "StickyHeaderComponent" << encode


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


listFooterNode : Html msg -> Attribute msg
listFooterNode =
    property "ListFooterComponent" << encode


listHeaderComponent : (() -> Html msg) -> Attribute msg
listHeaderComponent =
    property "ListHeaderComponent" << encode


listHeaderComponentStyle =
    property "listHeaderComponentStyle" << encode


listHeaderNode : Html msg -> Attribute msg
listHeaderNode =
    property "ListHeaderComponent" << encode


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


componentModel : a -> Attribute msg
componentModel =
    property "componentModel" << encode


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


autoCapitalize =
    property "autoCapitalize" << Encode.string


autoCorrect =
    property "autoCorrect" << Encode.bool


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


placeholderTextColor =
    property "placeholderTextColor" << Encode.string


secureTextEntry =
    property "secureTextEntry" << Encode.bool


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


overScrollMode =
    property "overScrollMode" << Encode.string


nestedScrollEnabled =
    property "nestedScrollEnabled" << Encode.bool


maximumZoomScale =
    property "maximumZoomScale" << Encode.float


keyboardShouldPersistTaps =
    property "keyboardShouldPersistTaps" << Encode.string


maintainVisibleContentPosition : { minIndexForVisible : Float, autoscrollToTopThreshold : Float } -> Attribute msg
maintainVisibleContentPosition =
    property "maintainVisibleContentPosition" << encode


minimumZoomScale =
    property "minimumZoomScale" << Encode.float


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
    property "supportedOrientations" << Encode.list Encode.string


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


textContentType =
    property "textContentType" << Encode.string


shadowColor =
    property "shadowColor" << Encode.string


shadowOpacity =
    property "shadowOpacity" << Encode.float


themeVariant =
    property "themeVariant" << Encode.string


shadowRadius =
    property "shadowRadius" << Encode.float


shadowOffset : { width : Float, height : Float } -> Attribute msg
shadowOffset =
    property "shadowOffset" << encode
