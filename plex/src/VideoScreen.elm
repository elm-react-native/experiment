module VideoScreen exposing (videoScreen)

import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..))
import ReactNative exposing (fragment, ionicon, null, touchableOpacity, touchableWithoutFeedback, view)
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


videoUri ratingKey client =
    client.serverAddress
        ++ "/video/:/transcode/universal/start.m3u8?path=%2Flibrary%2Fmetadata%2F"
        ++ ratingKey
        ++ "&fastSeek=1&protocol=hls&X-Plex-Model=bundled&X-Plex-Device=iOS&X-Plex-Token="
        ++ client.token


videoScreen : HomeModel -> { ratingKey : String, viewOffset : Maybe Int } -> Html Msg
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
        [ video
            [ source { uri = videoUri ratingKey m.client }
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
