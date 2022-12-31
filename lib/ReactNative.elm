module ReactNative exposing
    ( KeyboardType
    , activityIndicator
    , button
    , drawerLayoutAndroid
    , flatList
    , fragment
    , image
    , imageBackground
    , inputAccessoryView
    , keyboardAvoidingView
    , modal
    , null
    , pressable
    , refreshControl
    , require
    , safeAreaView
    , scrollView
    , sectionList
    , statusBar
    , str
    , switch
    , text
    , textInput
    , touchableHighlight
    , touchableNativeFeedback
    , touchableOpacity
    , touchableWithoutFeedback
    , view
    , virtualizedList
    )

import Html exposing (node)
import Json.Encode as Encode
import ReactNative.FlatList as FlatList
import ReactNative.Properties exposing (property)
import ReactNative.SectionList as SectionList
import ReactNative.VirtualizedList as VirtualizedList


{-| <https://lefkowitz.me/visual-guide-to-react-native-textinput-keyboardtype-options/>
-}
type KeyboardType
    = DefaultType
    | NumberPad
    | DecimalPad
    | Numeric
    | EmailAddress
    | PhonePad
    | Url
    | AsciiCapable
    | NumbersAndPunctuation
    | NamePhonePad
    | Twitter
    | WebSearch
    | VisiblePassword


str =
    Html.text


text =
    node "Text"


view =
    node "View"


refreshControl props =
    node "RefreshControl" props []


activityIndicator =
    node "ActivityIndicator"


button =
    node "Button"


image =
    node "Image"


imageBackground =
    node "ImageBackground"


keyboardAvoidingView =
    node "KeyboardAvoidingView"


modal =
    node "Modal"


pressable =
    node "Pressable"


scrollView =
    node "ScrollView"


sectionList =
    SectionList.sectionList


flatList =
    FlatList.flatList


virtualizedList =
    VirtualizedList.virtualizedList


statusBar =
    node "StatusBar"


switch =
    node "Switch"


textInput =
    node "TextInput"


touchableHighlight =
    node "TouchableHighlight"


touchableOpacity =
    node "TouchableOpacity"


touchableWithoutFeedback =
    node "TouchableWithoutFeedback"


drawerLayoutAndroid =
    node "DrawerLayoutAndroid"


touchableNativeFeedback =
    node "TouchableNativeFeedback"


inputAccessoryView =
    node "InputAccessoryView"


safeAreaView =
    node "SafeAreaView"


require : String -> String
require =
    identity


fragment =
    node "Fragment"


null =
    fragment [] []
