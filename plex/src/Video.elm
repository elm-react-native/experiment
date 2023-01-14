module Video exposing (controls, fullscreen, fullscreenAutorotate, fullscreenOrientation, onError, onErrorMessage, onFullscreenPlayerDidDismiss, onFullscreenPlayerWillDismiss, onSeek, paused, video)

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
