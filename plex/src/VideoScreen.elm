module VideoScreen exposing (videoScreen)

import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (HomeModel, Msg(..))
import ReactNative exposing (fragment, ionicon, null, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.Properties exposing (color, component, componentModel, getId, name, options, size, source, style)
import Video
    exposing
        ( controls
        , fullscreen
        , fullscreenAutorotate
        , fullscreenOrientation
        , onErrorMessage
        , onFullscreenPlayerDidDismiss
        , video
        )


videoUri ratingKey client =
    client.serverAddress
        ++ "/video/:/transcode/universal/start.m3u8?path=%2Flibrary%2Fmetadata%2F"
        ++ ratingKey
        ++ "&protocol=hls&X-Plex-Model=bundled&X-Plex-Device=iOS&X-Plex-Token="
        ++ client.token


videoScreen : HomeModel -> { ratingKey : String } -> Html Msg
videoScreen m { ratingKey } =
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
