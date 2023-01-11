module Video exposing (..)

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
    on "onFullscreenPlayerWillDismiss"


onFullscreenPlayerDidDismiss =
    on "onFullscreenPlayerDidDismiss"
