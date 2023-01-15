module VideoScreen exposing (videoScreen)

import Api
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..), VideoPlayer, isVideoUrlReady)
import ReactNative exposing (fragment, ionicon, null, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.Dimensions as Dimensions
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (color, component, componentModel, getId, name, options, size, source, style)
import Video
    exposing
        ( contentStartTime
        , controls
        , fullscreen
        , fullscreenAutorotate
        , fullscreenOrientation
        , onBuffer
        , onErrorMessage
        , onFullscreenPlayerDidDismiss
        , onPlaybackStateChanged
        , onProgress
        , pictureInPicture
        , playWhenInactive
        , progressUpdateInterval
        , seekOnStart
        , video
        )


videoUri : String -> String -> Api.Client -> Dimensions.DisplayMetrics -> String
videoUri ratingKey sessionId client screenMetrics =
    Api.pathToAuthedUrl "/video/:/transcode/universal/start.m3u8" client
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
        ++ ("&X-Plex-Token=" ++ client.token)
        ++ ("&X-Plex-Client-Identifier=" ++ client.id)
        ++ ("&X-Pler-Session-Identifier=" ++ sessionId)


videoScreen :
    HomeModel
    ->
        { ratingKey : String
        , viewOffset : Maybe Int
        }
    -> Html Msg
videoScreen m { ratingKey, viewOffset } =
    view
        [ style
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            , backgroundColor = "black"
            , position = "absolute"
            , top = 0
            , left = 0
            , bottom = 0
            , right = 0
            }
        ]
        [ if isVideoUrlReady m.videoPlayer then
            video
                [ source { uri = videoUri ratingKey m.videoPlayer.sessionId m.client m.videoPlayer.screenMetrics }
                , controls True
                , fullscreen True
                , fullscreenOrientation "landscape"
                , fullscreenAutorotate True
                , playWhenInactive True
                , pictureInPicture True
                , seekOnStart (Maybe.withDefault 0 viewOffset)
                , onErrorMessage PlayVideoError
                , onPlaybackStateChanged OnVideoPlaybackStateChanged
                , onBuffer OnVideoBuffer
                , onProgress (\p -> OnVideoProgress p.currentTime)
                , style
                    { position = "absolute"
                    , top = 0
                    , left = 0
                    , bottom = 0
                    , right = 0
                    }
                ]
                []

          else
            null
        ]
