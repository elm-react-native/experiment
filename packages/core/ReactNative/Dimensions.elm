module ReactNative.Dimensions exposing
    ( DimensionsValue
    , ScaledSize
    , dimensionsValueDecoder
    , scaledSizeDecoder
    , getScreen
    , getWindow
    , initialDimensionsValue
    , initialScaledSize
    , onChange
    )

import Browser
import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Task exposing (Task)


type alias ScaledSize =
    { width : Float
    , height : Float
    , scale : Float
    , fontScale : Float
    }


initialScaledSize : ScaledSize
initialScaledSize =
    { width = 0
    , height = 0
    , scale = 0
    , fontScale = 0
    }


scaledSizeDecoder : Decoder ScaledSize
scaledSizeDecoder =
    Decode.map4 ScaledSize
        (Decode.field "width" Decode.float)
        (Decode.field "height" Decode.float)
        (Decode.field "scale" Decode.float)
        (Decode.field "fontScale" Decode.float)


type alias DimensionsValue =
    { window : ScaledSize
    , screen : ScaledSize
    }


initialDimensionsValue : DimensionsValue
initialDimensionsValue =
    { window = initialScaledSize
    , screen = initialScaledSize
    }


dimensionsValueDecoder : Decoder DimensionsValue
dimensionsValueDecoder =
    Decode.map2 DimensionsValue
        (Decode.field "window" scaledSizeDecoder)
        (Decode.field "screen" scaledSizeDecoder)


get : String -> Task Never ScaledSize
get dim =
    Task.succeed initialScaledSize


getWindow : Task Never ScaledSize
getWindow =
    get "window"


getScreen : Task Never ScaledSize
getScreen =
    get "screen"


onChange : Decoder msg -> Sub msg
onChange decoder =
    onMouseDown decoder
