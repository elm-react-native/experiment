module VideoScreen exposing (videoScreen)

import Api
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..), VideoPlayer, isVideoUrlReady)
import ReactNative exposing (fragment, null, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (color, component, componentModel, getId, name, options, size, source, style)
import ReactNative.StyleSheet as StyleSheet
import ReactNative.Video
    exposing
        ( contentStartTime
        , controls
        , fullscreen
        , fullscreenAutorotate
        , fullscreenOrientation
        , onBuffer
        , onEnd
        , onErrorMessage
        , onFullscreenPlayerDidDismiss
        , onFullscreenPlayerWillDismiss
        , onPlaybackStateChanged
        , onProgress
        , onReadyForDisplay
        , pictureInPicture
        , playWhenInactive
        , progressUpdateInterval
        , seekOnStart
        , video
        )
import Time


videoUri : DisplayMetrics -> VideoPlayer -> Api.Client -> String
videoUri screenMetrics { ratingKey, sessionId } client =
    Api.clientRequestUrl "/video/:/transcode/universal/start.m3u8" client
        ++ ("&path=%2Flibrary%2Fmetadata%2F" ++ ratingKey)
        ++ "&fastSeek=1"
        ++ "&mediaBufferSize=102400"
        ++ "&protocol=hls"
        ++ "&X-Plex-Model=bundled"
        ++ ("&X-Plex-Device-Screen-Resolution=" ++ String.fromFloat screenMetrics.width ++ "x" ++ String.fromFloat screenMetrics.height)
        ++ (if Platform.os == "ios" then
                "&X-Plex-Device=iOS"

            else if Platform.os == "android" then
                "&X-Plex-Device=android"

            else
                ""
           )
        ++ ("&X-Pler-Session-Identifier=" ++ sessionId)


styles =
    StyleSheet.create
        { fullscreen =
            { position = "absolute"
            , top = 0
            , left = 0
            , bottom = 0
            , right = 0
            , backgroundColor = "black"
            }
        }


videoScreen : HomeModel -> () -> Html Msg
videoScreen m _ =
    if isVideoUrlReady m.videoPlayer then
        video
            [ source { uri = videoUri m.screenMetrics m.videoPlayer m.client }
            , controls True
            , fullscreenOrientation "landscape"
            , fullscreenAutorotate True
            , playWhenInactive True
            , pictureInPicture True
            , seekOnStart m.videoPlayer.initialPlaybackTime
            , onErrorMessage PlayVideoError
            , onEnd <| Decode.succeed OnVideoEnd
            , onBuffer OnVideoBuffer
            , onProgress (\p -> OnVideoProgress p.currentTime)
            , style styles.fullscreen
            ]
            []

    else
        null
