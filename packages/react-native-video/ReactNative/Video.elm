module ReactNative.Video exposing (PlayerProgress, allowsExternalPlayback, contentStartTime, controls, disableDisconnectError, fullscreen, fullscreenAutorotate, fullscreenOrientation, minLoadRetryCount, onBuffer, onEnd, onError, onErrorMessage, onFullscreenPlayerDidDismiss, onFullscreenPlayerWillDismiss, onLoad, onPlaybackStateChanged, onProgress, onReadyForDisplay, onSeek, paused, pictureInPicture, playWhenInactive, playerProgressDecoder, preventsDisplaySleepDuringVideoPlayback, progressUpdateInterval, rate, repeat, seekTime, video)

import Html exposing (Attribute, Html, node)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative.Events exposing (on, onFloat)
import ReactNative.Properties exposing (property)


video =
    node "Video"


controls =
    property "controls" << Encode.bool


allowsExternalPlayback =
    property "allowsExternalPlayback" << Encode.bool


fullscreen =
    property "fullscreen" << Encode.bool


fullscreenAutorotate =
    property "fullscreenAutorotate" << Encode.bool


fullscreenOrientation =
    property "fullscreenOrientation" << Encode.string


paused =
    property "paused" << Encode.bool


playWhenInactive =
    property "playWhenInactive" << Encode.bool


pictureInPicture =
    property "pictureInPicture" << Encode.bool


preventsDisplaySleepDuringVideoPlayback =
    property "preventsDisplaySleepDuringVideoPlayback" << Encode.bool


progressUpdateInterval =
    property "progressUpdateInterval" << Encode.int


rate =
    property "rate" << Encode.float


repeat =
    property "repeat" << Encode.bool


minLoadRetryCount =
    property "minLoadRetryCount" << Encode.int


disableDisconnectError =
    property "disableDisconnectError" << Encode.bool


contentStartTime =
    property "contentStartTime" << Encode.int


seekTime =
    property "seekTime" << Encode.int



-- EVENTS


onFullscreenPlayerWillDismiss =
    on "fullscreenPlayerWillDismiss"


onFullscreenPlayerDidDismiss =
    on "fullscreenPlayerDidDismiss"


onError =
    on "error"


onErrorMessage : (String -> msg) -> Attribute msg
onErrorMessage tagger =
    on "error" <| Decode.map tagger <| Decode.at [ "error", "localizedDescription" ] Decode.string


onSeek =
    on "seek"


onEnd =
    on "end"


onLoad =
    on "load"


onReadyForDisplay =
    on "readyForDisplay"


type alias PlayerProgress =
    { currentTime : Int
    , playableDuration : Int
    , seekableDuration : Int
    }


playerProgressDecoder : Decoder PlayerProgress
playerProgressDecoder =
    Decode.map3
        (\currentTime playableDuration seekableDuration ->
            PlayerProgress (round <| currentTime * 1000) (round <| playableDuration * 1000) (round <| seekableDuration * 1000)
        )
        (Decode.field "currentTime" Decode.float)
        (Decode.field "playableDuration" Decode.float)
        (Decode.field "seekableDuration" Decode.float)


onProgress : (PlayerProgress -> msg) -> Attribute msg
onProgress tagger =
    on "progress" <| Decode.map tagger <| playerProgressDecoder


onBuffer : (Bool -> msg) -> Attribute msg
onBuffer tagger =
    on "buffer" <| Decode.map tagger <| Decode.field "isBuffering" Decode.bool


onPlaybackStateChanged : (Bool -> msg) -> Attribute msg
onPlaybackStateChanged tagger =
    on "playbackStateChanged" <| Decode.map tagger <| Decode.field "isPlaying" Decode.bool
