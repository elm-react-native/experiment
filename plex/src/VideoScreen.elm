module VideoScreen exposing (videoScreen)

import Api
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..))
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
        , onErrorMessage
        , onFullscreenPlayerDidDismiss
        , pictureInPicture
        , playWhenInactive
        , seekOnStart
        , video
        )


videoUri : String -> Api.Client -> Dimensions.DisplayMetrics -> String
videoUri ratingKey client screenMetrics =
    client.serverAddress
        ++ "/video/:/transcode/universal/start.m3u8?path=%2Flibrary%2Fmetadata%2F"
        ++ ratingKey
        ++ "&fastSeek=1&mediaBufferSize=102400&protocol=hls&X-Plex-Model=bundled"
        ++ ("X-Plex-Device-Screen-Resolution=" ++ String.fromFloat screenMetrics.width ++ "x" ++ String.fromFloat screenMetrics.height)
        ++ (if Platform.os == "ios" then
                "&X-Plex-Device=iOS"

            else if Platform.os == "android" then
                "&X-Plex-Device=android"

            else
                ""
           )
        ++ ("&X-Plex-Token=" ++ client.token)


videoScreen : HomeModel -> { ratingKey : String, viewOffset : Maybe Int, screenMetrics : Dimensions.DisplayMetrics } -> Html Msg
videoScreen m { ratingKey, viewOffset, screenMetrics } =
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
        [ video
            [ source { uri = videoUri ratingKey m.client screenMetrics }
            , controls True
            , fullscreen True
            , fullscreenOrientation "landscape"
            , fullscreenAutorotate True
            , onErrorMessage PlayVideoError
            , onFullscreenPlayerDidDismiss <| Decode.succeed StopPlayVideo
            , playWhenInactive True
            , pictureInPicture True
            , seekOnStart (Maybe.withDefault 0 viewOffset)
            , style
                { position = "absolute"
                , top = 0
                , left = 0
                , bottom = 0
                , right = 0
                }
            ]
            []
        ]
