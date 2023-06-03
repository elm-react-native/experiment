module ReactNative.TextInput exposing (..)

import Html exposing (Attribute, Html, node)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative.Events exposing (on)
import ReactNative.Properties exposing (property)
import Task exposing (Task)



-- Properties


allowFontScaling =
    property "allowFontScaling" << Encode.bool


autoCapitalize =
    property "autoCapitalize" << Encode.string


autoComplete =
    property "autoComplete" << Encode.string


autoCorrect =
    property "autoCorrect" << Encode.bool


autoFocus =
    property "autoFocus" << Encode.bool


blurOnSubmit =
    property "blurOnSubmit" << Encode.bool


caretHidden =
    property "caretHidden" << Encode.bool


clearButtonMode =
    property "clearButtonMode" << Encode.string


clearTextOnFocus =
    property "clearTextOnFocus" << Encode.string


contextMenuHidden =
    property "contextMenuHidden" << Encode.bool


dataDetectorType =
    property "dataDetectorTypes" << Encode.string


dataDetectorTypes =
    property "dataDetectorTypes" << Encode.list Encode.string


defaultValue =
    property "defaultValue" << Encode.string


cursorColor =
    property "cursorColor" << Encode.string


editable =
    property "editable" << Encode.bool


enablesReturnKeyAutomatically =
    property "enablesReturnKeyAutomatically" << Encode.bool


{-| Determines what text should be shown to the return key. Has precedence over the returnKeyType prop.
-}
enterKeyHint =
    property "enterKeyHint" << Encode.string


importantForAutofill =
    property "importantForAutofill" << Encode.string


inlineImageLeft =
    property "inlineImageLeft" << Encode.string


inlineImagePadding =
    property "inlineImagePadding" << Encode.int


inputAccessoryViewID =
    property "inputAccessoryViewID" << Encode.string


inputMode =
    property "inputMode" << Encode.string


keyboardAppearance =
    property "keyboardAppearance" << Encode.string


keyboardType =
    property "keyboardType" << Encode.string


maxFontSizeMultiplier =
    property "maxFontSizeMultiplier" << Encode.float


returnKeyLabel =
    property "returnKeyLabel" << Encode.string


{-| Determines how the return key should look. On Android you can also use returnKeyLabel.

Cross platform

  - done
  - go
  - next
  - search
  - send

Android Only

  - none
  - previous

iOS Only

  - default
  - emergency-call
  - google
  - join
  - route
  - yahoo

-}
returnKeyType =
    property "returnKeyType" << Encode.string


rows =
    property "rows" << Encode.int


scrollEnabled =
    property "scrollEnabled" << Encode.bool


secureTextEntry =
    property "secureTextEntry" << Encode.bool


selection start end =
    property "selection" <|
        Encode.object
            [ ( "start", Encode.float start )
            , ( "end", Encode.float end )
            ]


selectionColor =
    property "selectionColor" << Encode.string


selectTextOnFocus =
    property "selectTextOnFocus" << Encode.bool


showSoftInputOnFocus =
    property "showSoftInputOnFocus" << Encode.bool


textAlign =
    property "textAlign" << Encode.string


textContentType =
    property "textContentType" << Encode.string


passwordRules =
    property "passwordRules" << Encode.string


textBreakStrategy =
    property "textBreakStrategy" << Encode.string


underlineColorAndroid =
    property "underlineColorAndroid" << Encode.string



-- Events


onEndEditing =
    on "endEditing"



-- Methods


focus : String -> Task Never ()
focus id =
    Task.succeed ()


blur : String -> Task Never ()
blur id =
    Task.succeed ()


clear : String -> Task Never ()
clear id =
    Task.succeed ()


isFocused : String -> Task Never Bool
isFocused id =
    Task.succeed False
