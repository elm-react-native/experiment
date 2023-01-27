port module Subtitle exposing (startSubtitle, stopSubtitle, subtitleReceiver)

import Model exposing (Dialogue)


port startSubtitle : { ratingKey : String, url : String } -> Cmd msg


port stopSubtitle : () -> Cmd msg


port subtitleReceiver : (List Dialogue -> msg) -> Sub msg
