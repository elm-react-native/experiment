module Media exposing (Media, MediaPart, MediaStream, mediaDecoder, streamDecoder)

import Json.Decode
import Json.Encode
import Utils as Util


type alias Media =
    { id : Int --  Unique ID associated with the item.
    , duration : Int --    The length of the item in milliseconds.
    , parts : List MediaPart
    }


type alias MediaPart =
    { id : Int --  Unique ID associated with the part.
    , streams : List MediaStream
    }


type alias MediaStream =
    { id : Int -- 4230,
    , streamType : Int -- 1 video, 2 audio, 3 subtitle,
    , default : Bool -- true,
    , codec : String -- "h264",
    , index : Int -- 0,
    , displayTitle : String -- "1080p (H.264)",
    , extendedDisplayTitle : String -- "1080p (H.264)"
    , sourceKey : String
    , selected : Bool
    , language : String
    }


mediaDecoder : Json.Decode.Decoder Media
mediaDecoder =
    Json.Decode.succeed
        (\id duration parts ->
            { id = id
            , duration = duration
            , parts = parts
            }
        )
        |> decodeAndMap (Json.Decode.field "id" Json.Decode.int)
        |> decodeAndMap (Json.Decode.field "duration" Json.Decode.int)
        |> decodeAndMap (Util.maybeEmptyList <| Json.Decode.field "Part" (Json.Decode.list decodeMediaPart))


decodeMediaPart : Json.Decode.Decoder MediaPart
decodeMediaPart =
    Json.Decode.succeed
        (\id streams ->
            { id = id
            , streams = streams
            }
        )
        |> decodeAndMap (Json.Decode.field "id" Json.Decode.int)
        |> decodeAndMap (Util.maybeEmptyList <| Json.Decode.field "Stream" (Json.Decode.list streamDecoder))


streamDecoder : Json.Decode.Decoder MediaStream
streamDecoder =
    Json.Decode.succeed
        (\id streamType default codec index displayTitle extendedDisplayTitle sourceKey selected language ->
            { id = id
            , streamType = streamType
            , default = default
            , codec = codec
            , index = index
            , displayTitle = displayTitle
            , extendedDisplayTitle = extendedDisplayTitle
            , sourceKey = sourceKey
            , selected = selected
            , language = language
            }
        )
        |> decodeAndMap (Json.Decode.field "id" Json.Decode.int)
        |> decodeAndMap (Json.Decode.field "streamType" Json.Decode.int)
        |> decodeAndMap (Util.maybeFalse <| Json.Decode.field "default" Json.Decode.bool)
        |> decodeAndMap (Json.Decode.field "codec" Json.Decode.string)
        |> decodeAndMap (Util.maybeZero <| Json.Decode.field "index" Json.Decode.int)
        |> decodeAndMap (Json.Decode.field "displayTitle" Json.Decode.string)
        |> decodeAndMap (Json.Decode.field "extendedDisplayTitle" Json.Decode.string)
        |> decodeAndMap (Util.maybeEmptyString <| Json.Decode.field "sourceKey" Json.Decode.string)
        |> decodeAndMap (Util.maybeFalse <| Json.Decode.field "selected" Json.Decode.bool)
        |> decodeAndMap (Util.maybeEmptyString <| Json.Decode.field "language" Json.Decode.string)


decodeAndMap : Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b
decodeAndMap =
    Json.Decode.map2 (|>)
