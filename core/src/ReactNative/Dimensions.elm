module ReactNative.Dimensions exposing
    ( DimensionsValue
    , DisplayMetrics
    , dimensionsValueDecoder
    , displayMetricsDecoder
    , getScreen
    , getWindow
    , initialDimensionsValue
    , initialDisplayMetrics
    , onChange
    )

import Browser
import Browser.Events exposing (onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Task exposing (Task)


type alias DisplayMetrics =
    { width : Float
    , height : Float
    , scale : Float
    , fontScale : Float
    }


initialDisplayMetrics : DisplayMetrics
initialDisplayMetrics =
    { width = 0
    , height = 0
    , scale = 0
    , fontScale = 0
    }


displayMetricsDecoder : Decoder DisplayMetrics
displayMetricsDecoder =
    Decode.map4 DisplayMetrics
        (Decode.field "width" Decode.float)
        (Decode.field "height" Decode.float)
        (Decode.field "scale" Decode.float)
        (Decode.field "fontScale" Decode.float)


type alias DimensionsValue =
    { window : DisplayMetrics
    , screen : DisplayMetrics
    }


initialDimensionsValue : DimensionsValue
initialDimensionsValue =
    { window = initialDisplayMetrics
    , screen = initialDisplayMetrics
    }


dimensionsValueDecoder : Decoder DimensionsValue
dimensionsValueDecoder =
    Decode.map2 DimensionsValue
        (Decode.field "window" displayMetricsDecoder)
        (Decode.field "screen" displayMetricsDecoder)


get : String -> Task Never DisplayMetrics
get dim =
    Task.succeed initialDisplayMetrics


getWindow : Task Never DisplayMetrics
getWindow =
    get "window"


getScreen : Task Never DisplayMetrics
getScreen =
    get "screen"


onChange : Decoder msg -> Sub msg
onChange decoder =
    onMouseDown decoder
