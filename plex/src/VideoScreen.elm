module VideoScreen exposing (videoScreen)

import Api
import Components exposing (text)
import EntityScreen exposing (episodeTitle)
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..), PlaybackState(..), SeekStage(..), VideoPlayer, VideoPlayerControlAction(..), dialogueDecoder, isVideoUrlReady)
import ReactNative exposing (activityIndicator, button, fragment, image, null, require, str, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import ReactNative.Events exposing (onFloatValueChange, onPress)
import ReactNative.Icon exposing (ionicon, materialIcon)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (color, component, componentModel, getId, intValue, name, options, resizeMode, size, source, stringSize, style, title)
import ReactNative.Slider as Slider exposing (maximumValue, minimumTrackTintColor, minimumValue, onSlidingComplete, onSlidingStart, slider, thumbTintColor)
import ReactNative.StyleSheet as StyleSheet
import ReactNative.Video
    exposing
        ( allowsExternalPlayback
        , contentStartTime
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
        , onSeek
        , paused
        , pictureInPicture
        , playWhenInactive
        , progressUpdateInterval
        , seekTime
        , video
        )
import SubtitleStream exposing (subtitleStream)
import Theme
import Time


padZero n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


formatDuration : Int -> Int -> String
formatDuration d maximum =
    let
        total =
            d // 1000

        totalMins =
            total // 60

        totalHours =
            total // 3600

        seconds =
            total - totalMins * 60

        mins =
            totalMins - totalHours * 60

        hideHour =
            maximum < 3600000

        hideMin =
            maximum < 60000
    in
    (if hideHour then
        ""

     else
        padZero totalHours ++ ":"
    )
        ++ (if hideMin then
                ""

            else
                padZero mins ++ ":"
           )
        ++ padZero seconds


videoUri : DisplayMetrics -> VideoPlayer -> Api.Client -> String
videoUri screenMetrics { sessionId, metadata } client =
    Api.clientRequestUrl "/video/:/transcode/universal/start.m3u8" client
        ++ ("&path=%2Flibrary%2Fmetadata%2F" ++ metadata.ratingKey)
        ++ "&hasMDE=1"
        ++ "&mediaIndex=0"
        ++ "&partIndex=0"
        ++ "&protocol=hls"
        ++ "&fastSeek=1"
        ++ "&directPlay=0"
        ++ "&directStream=1"
        ++ "&subtitleSize=100"
        ++ "&audioBoost=100"
        ++ "&location=lan"
        ++ "&addDebugOverlay=0"
        ++ "&autoAdjustQuality=0"
        ++ "&directStreamAudio=1"
        ++ "&mediaBufferSize=102400"
        ++ "&subtitles=auto"
        ++ "&Accept-Language=en"
        ++ "&X-Plex-Client-Profile-Extra=append-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%252Cac3%252Ceac3%26protocol%3Dhls%29"
        ++ "&X-Plex-Incomplete-Segments=1"
        ++ "&X-Plex-Product=Plex%20Web"
        ++ "&X-Plex-Version=4.87.2"
        ++ "&X-Plex-Platform=Safari"
        ++ "&X-Plex-Platform-Version=605.1"
        ++ "&X-Plex-Features=external-media%2Cindirect-media%2Chub-style-list"
        ++ "&X-Plex-Model=bundled"
        ++ (if Platform.os == "ios" then
                "&X-Plex-Device=iOS"

            else if Platform.os == "android" then
                "&X-Plex-Device=android"

            else
                ""
           )
        ++ "&X-Plex-Device-Name=Safari"
        --++ "&X-Plex-Device-Screen-Resolution=980x1646%2C393x852"
        ++ ("&X-Plex-Device-Screen-Resolution=" ++ String.fromFloat screenMetrics.width ++ "x" ++ String.fromFloat screenMetrics.height)
        ++ "&X-Plex-Language=en"
        ++ ("&X-Pler-Session-Identifier=" ++ sessionId)
        ++ ("&session=" ++ sessionId)


getSubtitleUrl client screenMetrics ratingKey sessionId =
    Api.clientRequestUrl "/video/:/transcode/universal/subtitles" client
        ++ ("&hasMDE=1&path=%2Flibrary%2Fmetadata%2F" ++ ratingKey)
        ++ "&mediaIndex=0"
        ++ "&partIndex=0"
        ++ "&protocol=hls"
        ++ "&fastSeek=1"
        ++ "&directPlay=0"
        ++ "&directStream=1"
        ++ "&subtitleSize=100"
        ++ "&audioBoost=100"
        ++ "&location=lan"
        ++ "&addDebugOverlay=0"
        ++ "&autoAdjustQuality=0"
        ++ "&directStreamAudio=1"
        ++ "&mediaBufferSize=102400"
        ++ "&subtitles=auto"
        ++ "&Accept-Language=en"
        ++ "&X-Plex-Client-Profile-Extra=append-transcode-target-codec%28type%3DvideoProfile%26context%3Dstreaming%26audioCodec%3Daac%252Cac3%252Ceac3%26protocol%3Dhls%29"
        ++ "&X-Plex-Incomplete-Segments=1"
        ++ "&X-Plex-Product=Plex%20Web"
        ++ "&X-Plex-Version=4.87.2"
        ++ "&X-Plex-Platform=Safari"
        ++ "&X-Plex-Platform-Version=605.1"
        ++ "&X-Plex-Features=external-media%2Cindirect-media%2Chub-style-list"
        ++ "&X-Plex-Model=bundled"
        ++ "&X-Plex-Device=iOS"
        ++ "&X-Plex-Device-Name=Safari"
        --++ "&X-Plex-Device-Screen-Resolution=980x1646%2C393x852"
        ++ ("&X-Plex-Device-Screen-Resolution=" ++ String.fromFloat screenMetrics.width ++ "x" ++ String.fromFloat screenMetrics.height)
        ++ "&X-Plex-Language=en"
        ++ ("&X-Pler-Session-Identifier=" ++ sessionId)
        ++ ("&session=" ++ sessionId)


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            , backgroundColor = "black"
            }
        , fullscreen =
            { position = "absolute"
            , top = 0
            , left = 0
            , bottom = 0
            , right = 0
            }
        , center =
            { justifyContent = "center"
            , alignItems = "center"
            , width = 40
            , height = 40
            , marginLeft = -20
            , marginTop = -20
            , position = "absolute"
            , left = "50%"
            , top = "50%"
            }
        , controls =
            { backgroundColor = "transparent"
            , position = "absolute"
            , bottom = 44
            , left = 4
            , right = 4
            }
        , subtitleContainer =
            { backgroundColor = "#00000060"
            , alignItems = "center"
            , justifyContent = "center"
            , paddingHorizontal = 5
            , paddingVertical = 3
            , width = "auto"
            , borderRadius = 3
            }
        , subtitle = { fontSize = 18 }
        }


videoTitle metadata =
    case metadata.typ of
        "episode" ->
            episodeTitle metadata

        _ ->
            metadata.title


videoPlayerControlsHeader : VideoPlayer -> Html Msg
videoPlayerControlsHeader videoPlayer =
    view
        [ style
            { position = "absolute"
            , top = 0
            , left = 0
            , width = "100%"
            , paddingTop = 30
            , alignItems = "center"
            , justifyContent = "center"
            }
        ]
        [ text [ style { fontSize = 16, fontWeight = "bold" } ]
            [ str <| videoTitle videoPlayer.metadata ]
        , view
            [ style { position = "absolute", right = 35, top = 25 } ]
            [ videoPlayerControlsIcon 25 "ios-close" StopPlayVideo ]
        ]


videoPlayerControlsIcon sz name pressMsg =
    ionicon name [ size sz, color "white", onPress <| Decode.succeed <| pressMsg ]


videoPlayerControlsImageIcon sz src label pressMsg =
    touchableOpacity
        [ onPress <| Decode.succeed <| pressMsg, style { flexDirection = "row", gap = 4, alignItems = "center" } ]
        [ image
            [ source src
            , style { width = sz, height = sz }
            ]
            []
        , if String.isEmpty label then
            null

          else
            text [ style { fontSize = 15, fontWeight = "bold" } ] [ str label ]
        ]


videoPlayerControlsBody : VideoPlayer -> Html Msg
videoPlayerControlsBody videoPlayer =
    view
        [ style
            { position = "absolute"
            , top = "50%"
            , height = 60
            , marginTop = -30
            , left = 0
            , width = "100%"
            }
        ]
        [ view
            [ style
                { display = "flex"
                , flexDirection = "row"
                , gap = 110
                , justifyContent = "center"
                , alignItems = "center"
                , flexGrow = 1
                }
            ]
            [ videoPlayerControlsImageIcon 35 (require "./assets/backward.png") "" <| VideoPlayerControl <| SeekAction SeekRelease (max 0 <| videoPlayer.playbackTime - 10 * 1000)
            , if videoPlayer.state == Playing then
                videoPlayerControlsIcon 55 "pause" <| VideoPlayerControl TogglePlay

              else
                videoPlayerControlsIcon 55 "play" <| VideoPlayerControl TogglePlay
            , videoPlayerControlsImageIcon 35 (require "./assets/forward.png") "" <| VideoPlayerControl <| SeekAction SeekRelease (min videoPlayer.metadata.duration <| videoPlayer.playbackTime + 10 * 1000)
            ]
        ]


videoPlayerControlsProgress videoPlayer =
    view
        [ style
            { flexDirection = "row"
            , alignItems = "center"
            , justifyContent = "space-around"
            , gap = 20
            , paddingHorizontal = 20
            , position = "absolute"
            , bottom = 50
            , width = "100%"
            }
        ]
        [ text
            [ style { fontSize = 14 } ]
            [ str <|
                formatDuration videoPlayer.playbackTime videoPlayer.metadata.duration
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
            [ str <|
                formatDuration (videoPlayer.metadata.duration - videoPlayer.playbackTime) videoPlayer.metadata.duration
            ]
        ]


videoPlayerControlsFooter videoPlayer =
    view
        [ style
            { flexDirection = "row"
            , justifyContent = "space-between"
            , paddingHorizontal = 80
            , height = 50
            , alignItems = "flex-start"
            , position = "absolute"
            , width = "100%"
            , bottom = 0
            }
        ]
        [ videoPlayerControlsImageIcon 25 (require "./assets/speed.png") "Speed (1x)" NoOp
        , videoPlayerControlsImageIcon 25 (require "./assets/lock-open.png") "Lock" NoOp
        , videoPlayerControlsImageIcon 25 (require "./assets/episodes.png") "Episodes" NoOp
        , videoPlayerControlsImageIcon 25 (require "./assets/subtitle.png") "Subtitles" NoOp
        , videoPlayerControlsImageIcon 25 (require "./assets/next-ep.png") "Next Episode" NoOp
        ]


videoPlayerControls : VideoPlayer -> Html Msg
videoPlayerControls videoPlayer =
    view
        [ style styles.fullscreen
        , style
            { display =
                if videoPlayer.showControls then
                    "flex"

                else
                    "none"
            , backgroundColor = "#00000060"
            }
        ]
        [ videoPlayerControlsHeader videoPlayer
        , videoPlayerControlsBody videoPlayer
        , videoPlayerControlsProgress videoPlayer
        , videoPlayerControlsFooter videoPlayer
        ]


subtitleText : String -> Html msg
subtitleText s =
    view [ style styles.subtitleContainer ]
        [ text [ style styles.subtitle ] [ str s ] ]


videoPlayerSubtitle { subtitle, playbackTime, seeking } =
    if seeking then
        null

    else
        let
            s =
                subtitle
                    |> List.filter
                        (\dialogue ->
                            if dialogue.start <= playbackTime && playbackTime <= dialogue.end then
                                let
                                    _ =
                                        Debug.log "dialogue" dialogue

                                    _ =
                                        Debug.log "playbackTime" playbackTime
                                in
                                True

                            else
                                False
                        )
                    |> List.map .text
                    |> String.join "\n"
                    |> String.trim
        in
        if String.isEmpty s then
            null

        else
            view
                [ style
                    { width = "100%"
                    , minHeight = 70
                    , bottom = 0
                    , left = 0
                    , position = "absolute"
                    , alignItems = "center"
                    }
                ]
                [ lazy subtitleText s ]


videoScreen : HomeModel -> () -> Html Msg
videoScreen ({ videoPlayer, screenMetrics, client } as m) _ =
    if isVideoUrlReady videoPlayer then
        view [ style styles.container ]
            [ video
                [ source { uri = videoUri screenMetrics videoPlayer client }
                , seekTime videoPlayer.seekTime
                , onErrorMessage PlayVideoError
                , onEnd <| Decode.succeed OnVideoEnd
                , onBuffer OnVideoBuffer
                , onProgress (\p -> OnVideoProgress p.currentTime)
                , onSeek <| Decode.succeed <| VideoPlayerControl <| SeekAction SeekEnd videoPlayer.playbackTime
                , style styles.fullscreen
                , allowsExternalPlayback False
                , paused <| (videoPlayer.state /= Playing || videoPlayer.seeking)
                , resizeMode "cover"
                ]
                []
            , subtitleStream
                [ SubtitleStream.url <| getSubtitleUrl client screenMetrics videoPlayer.metadata.ratingKey videoPlayer.sessionId
                , SubtitleStream.playbackTime videoPlayer.subtitleSeekTime
                , SubtitleStream.onDialogues <| Decode.map GotSubtitle <| Decode.list dialogueDecoder
                ]
                []
            , videoPlayerSubtitle videoPlayer
            , touchableWithoutFeedback
                [ onPress <| Decode.succeed ToggleVideoPlayerControls ]
                [ view [ style styles.fullscreen ]
                    [ videoPlayerControls videoPlayer
                    , if videoPlayer.isBuffering && not videoPlayer.seeking then
                        activityIndicator [ style styles.center, stringSize "large" ] []

                      else
                        null
                    ]
                ]
            ]

    else
        null
