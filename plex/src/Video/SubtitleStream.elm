module Video.SubtitleStream exposing (onDialogues, playbackTime, subtitleStream, subtitleStreamId, url)

import Json.Encode as Encode
import Model exposing (Dialogue)
import ReactNative exposing (node)
import ReactNative.Events exposing (on)
import ReactNative.Properties exposing (property)


subtitleStream =
    node "SubtitleStream"


url =
    property "url" << Encode.string


subtitleStreamId =
    property "subtitleStreamId" << Encode.int


playbackTime =
    property "playbackTime" << Encode.int


onDialogues =
    on "dialogues"
