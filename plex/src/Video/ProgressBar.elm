module Video.ProgressBar exposing (..)

import Browser
import Components exposing (text)
import Html exposing (Attribute, Html)
import Model exposing (Msg(..), SeekStage(..), VideoPlayer, VideoPlayerControlAction(..))
import ReactNative exposing (str, view)
import ReactNative.Events exposing (onFloatValueChange)
import ReactNative.Properties exposing (intValue, style)
import ReactNative.Slider as Slider exposing (maximumValue, minimumTrackTintColor, minimumValue, onSlidingComplete, onSlidingStart, slider, thumbTintColor)
import Theme
import Utils exposing (formatPlaybackTime)


videoPlayerControlsProgress : VideoPlayer -> Html Msg
videoPlayerControlsProgress videoPlayer =
    view
        [ style
            { flexDirection = "row"
            , alignItems = "center"
            , justifyContent = "center"
            , gap = 20
            , paddingHorizontal = 20
            , width = "100%"
            }
        ]
        [ text
            [ style { fontSize = 14 } ]
            [ str <|
                formatPlaybackTime (min videoPlayer.playbackTime videoPlayer.metadata.duration) videoPlayer.metadata.duration
            ]
        , slider
            [ minimumValue 0
            , maximumValue videoPlayer.metadata.duration
            , thumbTintColor Theme.themeColor
            , minimumTrackTintColor Theme.themeColor
            , intValue <| videoPlayer.playbackTime
            , style { flexGrow = 1, marginBottom = 2, alignSelf = "center" }
            , onSlidingStart <| round >> SeekAction SeekStart >> VideoPlayerControl
            , onFloatValueChange <| round >> SeekAction Seeking >> VideoPlayerControl
            , onSlidingComplete <| round >> SeekAction SeekRelease >> VideoPlayerControl
            ]
            []
        , text
            [ style { fontSize = 14 } ]
            [ str <| "-" ++ formatPlaybackTime (max 0 <| videoPlayer.metadata.duration - videoPlayer.playbackTime) videoPlayer.metadata.duration
            ]
        ]
