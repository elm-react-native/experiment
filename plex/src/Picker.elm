module Picker exposing (changeEventDecoder, dropdownIconColor, dropdownIconRippleColor, itemStyle, label, mode, numberOfLines, onValueChange, picker, pickerItem, prompt, selectedValue)

import Html exposing (Attribute)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative exposing (child, node)
import ReactNative.Events exposing (on)
import ReactNative.Properties exposing (encode, property)


picker =
    node "Picker"


pickerItem =
    child


selectedValue : comparable -> Attribute msg
selectedValue =
    property "selectedValue" << encode


changeEventDecoder =
    Decode.map2 (\item i -> { item = item, index = i })
        (Decode.index 0 Decode.string)
        (Decode.index 1 Decode.int)


onValueChange : ({ item : String, index : Int } -> msg) -> Attribute msg
onValueChange tagger =
    on "valueChange" <| Decode.map tagger changeEventDecoder


label =
    property "label" << Encode.string


itemStyle =
    property "itemStyle" << encode


numberOfLines =
    property "numberOfLines" << Encode.int



-- ANDROID


mode =
    property "mode" << Encode.string


dropdownIconColor =
    property "dropdownIconColor" << Encode.string


dropdownIconRippleColor =
    property "dropdownIconRippleColor" << Encode.string


prompt =
    property "prompt" << Encode.string
