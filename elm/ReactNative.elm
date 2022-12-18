module ReactNative exposing
    ( activityIndicator
    , button
    , drawerLayoutAndroid
    , flatList
    , image
    , imageBackground
    , inputAccessoryView
    , keyboardAvoidingView
    , modal
    , pressable
    , refreshControl
    , require
    , safeAreaView
    , scrollView
    , sectionList
    , statusBar
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
import Html.Attributes exposing (property)
import Json.Encode as Encode


text props str =
    node "Text" props [ Html.text str ]


view =
    node "View"


refreshControl b props =
    node "RefreshControl" (property "refreshing" b :: props)


activityIndicator =
    node "ActivityIndicator"


button =
    node "Button"


flatList =
    node "FlatList"


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
    node "SectionList"


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


virtualizedList =
    node "VirtualizedList"


drawerLayoutAndroid =
    node "DrawerLayoutAndroid"


touchableNativeFeedback =
    node "TouchableNativeFeedback"


inputAccessoryView =
    node "InputAccessoryView"


safeAreaView =
    node "SafeAreaView"


require : String -> String
require s =
    s
