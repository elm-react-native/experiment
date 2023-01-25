module ReactNative.Slider exposing (lowerLimit, maximumTrackImage, maximumTrackTintColor, maximumValue, maximumValueFloat, minimumTrackImage, minimumTrackTintColor, minimumValue, minimumValueFloat, onSlidingComplete, onSlidingStart, slider, step, tapToSeek, thumbImage, thumbTintColor, trackImage, upperLimit, vertical)

import Html exposing (Attribute, Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (node)
import ReactNative.Events exposing (on, onFloat)
import ReactNative.Properties exposing (property)


slider =
    node "Slider"


minimumValue =
    property "minimumValue" << Encode.int


maximumValue =
    property "maximumValue" << Encode.int


minimumValueFloat =
    property "minimumValue" << Encode.float


maximumValueFloat =
    property "maximumValue" << Encode.float


lowerLimit =
    property "lowerLimit" << Encode.float


upperLimit =
    property "upperLimit" << Encode.float


thumbImage =
    property "thumbImage" << Encode.string


tapToSeek =
    property "tapToSeek" << Encode.bool


step =
    property "step" << Encode.int


minimumTrackTintColor =
    property "minimumTrackTintColor" << Encode.string


maximumTrackTintColor =
    property "maximumTrackTintColor" << Encode.string


thumbTintColor =
    property "thumbTintColor" << Encode.string


trackImage =
    property "trackImage" << Encode.string


maximumTrackImage =
    property "maximumTrackImage" << Encode.string


minimumTrackImage =
    property "minimumTrackImage" << Encode.string


vertical =
    property "vertical" << Encode.bool


onSlidingComplete =
    onFloat "slidingComplete"


onSlidingStart =
    onFloat "slidingStart"
