module Video.VideoView exposing (PlayerProgress, onBuffering, onEnded, onError, onOpening, onPlaying, onProgress, paused, playerProgressDecoder, rate, seek, src, video)

import Html exposing (Attribute, Html, node)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative.Events exposing (on, onFloat)
import ReactNative.Properties exposing (property)


video =
    node "VideoView"


paused =
    property "paused" << Encode.bool


src =
    property "src" << Encode.string


rate =
    property "rate" << Encode.float


seek =
    property "seek" << Encode.float



-- EVENTS


onError =
    on "error"


onEnded =
    on "ended"


onOpening =
    on "opening"


type alias PlayerProgress =
    { currentTime : Int
    }


playerProgressDecoder : Decoder PlayerProgress
playerProgressDecoder =
    Decode.map PlayerProgress <| Decode.field "currentTime" Decode.int


onProgress : (PlayerProgress -> msg) -> Attribute msg
onProgress tagger =
    on "progress" <| Decode.map tagger <| playerProgressDecoder


onBuffering =
    on "buffering"


onPlaying =
    on "playing"
