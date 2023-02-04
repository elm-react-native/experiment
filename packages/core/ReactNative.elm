module ReactNative exposing
    ( KeyboardType
    , activityIndicator
    , button
    , child
    , drawerLayoutAndroid
    , flatList
    , fragment
    , image
    , imageBackground
    , inputAccessoryView
    , keyboardAvoidingView
    , modal
    , node
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
    , touchableScale
    , touchableWithoutFeedback
    , view
    , virtualizedList
    )

import Html exposing (Attribute, Html)
import Json.Encode as Encode
import ReactNative.FlatList as FlatList
import ReactNative.Properties exposing (name, property)
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


node =
    Html.node


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


pressable : List (Attribute msg) -> ({ state | pressed : Bool } -> Html msg) -> Html msg
pressable props children =
    node "Pressable" props []


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


touchableScale =
    node "TouchableScale"


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


child =
    node "Child"
