module ReactNative.BlurView exposing (blurAmount, blurType, blurView, downsampleFactor, overlayColor, reducedTransparencyFallbackColor)

import Browser
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import ReactNative exposing (node)
import ReactNative.Events exposing (on)
import ReactNative.Properties exposing (encode, property)


blurView =
    node "BlurView"


blurType =
    property "blurType" << Encode.string


blurAmount =
    property "blurAmount" << Encode.float


reducedTransparencyFallbackColor =
    property "reducedTransparencyFallbackColor" << Encode.string


downsampleFactor =
    property "downsampleFactor" << Encode.float


overlayColor =
    property "overlayColor" << Encode.string
