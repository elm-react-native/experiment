module Video exposing (contentStartTime, controls, disableDisconnectError, fullscreen, fullscreenAutorotate, fullscreenOrientation, minLoadRetryCount, onError, onErrorMessage, onFullscreenPlayerDidDismiss, onFullscreenPlayerWillDismiss, onSeek, paused, pictureInPicture, playWhenInactive, preventsDisplaySleepDuringVideoPlayback, progressUpdateInterval, rate, repeat, seekOnStart, video)

import Html exposing (Attribute, Html, node)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative.Events exposing (on)
import ReactNative.Properties exposing (property)


video =
    node "Video"


controls =
    property "controls" << Encode.bool


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
    property "progressUpdateInterval" << Encode.float


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


seekOnStart =
    property "seekOnStart" << Encode.int



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
