module VideoScreen exposing (videoScreen)

import Api
import Components exposing (onPinch, onTap, pinchableView, text)
import EntityScreen exposing (episodeTitle)
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..), PlaybackSpeed, PlaybackState(..), ScreenLockState(..), SeekStage(..), VideoPlayer, VideoPlayerControlAction(..), containsSubtitle, dialogueDecoder, isVideoUrlReady, playbackSpeedDecoder, playbackSpeedEncode, playbackSpeedList, playbackSpeedToRate)
import ReactNative exposing (activityIndicator, button, fragment, image, null, require, str, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.Animated as Animated
import ReactNative.ContextMenuIOS exposing (MenuItem, contextMenuButton, isMenuPrimaryAction, menuConfig, onPressMenuItem, pressEventMenuItemDecoder)
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import ReactNative.Events exposing (onFloatValueChange, onPress)
import ReactNative.Icon exposing (ionicon, materialIcon)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (color, component, componentModel, disabled, getId, intValue, name, options, pointerEvents, resizeMode, size, source, stringSize, style, title)
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
        , rate
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
    Animated.view
        [ style
            { position = "absolute"
            , left = 0
            , width = "100%"
            , paddingTop = 30
            , alignItems = "center"
            , justifyContent = "center"
            , top =
                Animated.multiply (Animated.create -20)
                    (Animated.subtract (Animated.create 1) videoPlayer.playerControlsAnimatedValue)
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


videoPlayerControlsImageIcon sz src label props =
    touchableOpacity
        (style { flexDirection = "row", gap = 4, alignItems = "center" } :: props)
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


videoPlayerControlsPressableImageIcon sz src label msg =
    videoPlayerControlsImageIcon sz src label <| [ onPress <| Decode.succeed msg ]


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
            [ videoPlayerControlsPressableImageIcon 35 (require "./assets/backward.png") "" <| VideoPlayerControl <| SeekAction SeekRelease (max 0 <| videoPlayer.playbackTime - 10 * 1000)
            , if videoPlayer.state == Playing then
                videoPlayerControlsIcon 55 "pause" <| VideoPlayerControl TogglePlay

              else
                videoPlayerControlsIcon 55 "play" <| VideoPlayerControl TogglePlay
            , videoPlayerControlsPressableImageIcon 35 (require "./assets/forward.png") "" <| VideoPlayerControl <| SeekAction SeekRelease (min videoPlayer.metadata.duration <| videoPlayer.playbackTime + 10 * 1000)
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
            , width = "100%"
            }
        ]
        [ text
            [ style { fontSize = 14 } ]
            [ str <|
                formatDuration (min videoPlayer.playbackTime videoPlayer.metadata.duration) videoPlayer.metadata.duration
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
                formatDuration (max 0 <| videoPlayer.metadata.duration - videoPlayer.playbackTime) videoPlayer.metadata.duration
            ]
        ]


playbackSpeedMenu : PlaybackSpeed -> Html Msg
playbackSpeedMenu playbackSpeed =
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map
                (\{ actionKey } ->
                    VideoPlayerControl <| ChangeSpeed <| playbackSpeedDecoder actionKey
                )
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , menuConfig
            { menuTitle = ""
            , menuItems =
                playbackSpeedList
                    |> List.map
                        (\speed ->
                            { speed = playbackSpeedEncode speed
                            , selected = speed == playbackSpeed
                            }
                        )
                    |> List.map
                        (\{ speed, selected } ->
                            { actionKey = speed
                            , actionTitle =
                                if selected then
                                    "✓ " ++ speed

                                else
                                    "    " ++ speed
                            }
                        )
            }
        ]
        [ let
            label =
                "Speed (" ++ playbackSpeedEncode playbackSpeed ++ ")"
          in
          videoPlayerControlsPressableImageIcon 20 (require "./assets/speed.png") label <| VideoPlayerControl ExtendTimeout
        ]


subtitleMenu : Bool -> Bool -> Html Msg
subtitleMenu haveSubtitle isDisplay =
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map
                (\{ actionKey } ->
                    VideoPlayerControl <| ChangeSubtitle <| actionKey == "On"
                )
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , disabled (not haveSubtitle)
        , menuConfig
            { menuTitle =
                if haveSubtitle then
                    ""

                else
                    "No subtitle"
            , menuItems =
                if haveSubtitle then
                    [ False, True ]
                        |> List.map
                            (\isOn ->
                                { label =
                                    if isOn then
                                        "On"

                                    else
                                        "Off"
                                , selected = isOn == isDisplay
                                }
                            )
                        |> List.map
                            (\{ label, selected } ->
                                { actionKey = label
                                , actionTitle =
                                    if selected then
                                        "✓ " ++ label

                                    else
                                        "    " ++ label
                                }
                            )

                else
                    []
            }
        ]
        [ videoPlayerControlsImageIcon 20
            (require "./assets/subtitle.png")
            "Subtitles"
            ((onPress <| Decode.succeed <| VideoPlayerControl ExtendTimeout)
                :: (if haveSubtitle then
                        []

                    else
                        [ style { opacity = 0.5 }
                        , disabled (not haveSubtitle)
                        ]
                   )
            )
        ]


videoPlayerControlsFooter : VideoPlayer -> Html Msg
videoPlayerControlsFooter videoPlayer =
    view
        [ style
            { flexDirection = "row"
            , justifyContent =
                if videoPlayer.screenLock == Unlocked then
                    "space-between"

                else
                    "center"
            , paddingHorizontal = 80
            , height =
                if videoPlayer.screenLock == Unlocked then
                    50

                else
                    80
            , alignItems = "flex-start"
            , width = "100%"
            }
        ]
        (if videoPlayer.screenLock == Unlocked then
            [ playbackSpeedMenu videoPlayer.playbackSpeed
            , videoPlayerControlsPressableImageIcon 20 (require "./assets/lock-open.png") "Lock" <| VideoPlayerControl <| ChangeScreenLock Locked
            , videoPlayerControlsPressableImageIcon 20 (require "./assets/episodes.png") "Episodes" <| VideoPlayerControl ExtendTimeout
            , subtitleMenu videoPlayer.haveSubtitle videoPlayer.showSubtitle
            , if videoPlayer.metadata.typ == "episode" then
                videoPlayerControlsPressableImageIcon 20 (require "./assets/next-ep.png") "Next Episode" <| VideoPlayerControl NextEpisode

              else
                null
            ]

         else
            [ touchableOpacity
                [ style
                    { alignItems = "center"
                    , justifyContent = "center"
                    }
                , onPress <|
                    Decode.succeed <|
                        VideoPlayerControl <|
                            ChangeScreenLock <|
                                if videoPlayer.screenLock == Locked then
                                    ConfirmUnlock

                                else
                                    Unlocked
                ]
                [ case videoPlayer.screenLock of
                    Locked ->
                        view
                            [ style
                                { backgroundColor = "white"
                                , borderRadius = 14
                                , overflow = "hidden"
                                , justifyContent = "center"
                                , alignItems = "center"
                                , width = 28
                                , height = 28
                                }
                            ]
                            [ image
                                [ source (require "./assets/lock-close.png")
                                , style { width = 20, height = 20 }
                                ]
                                []
                            ]

                    ConfirmUnlock ->
                        view
                            [ style
                                { backgroundColor = "white"
                                , borderRadius = 14
                                , overflow = "hidden"
                                , justifyContent = "center"
                                , alignItems = "center"
                                , height = 28
                                , flexDirection = "row"
                                , gap = 3
                                , paddingHorizontal = 10
                                }
                            ]
                            [ image
                                [ source (require "./assets/lock-open-black.png")
                                , style { width = 20, height = 20 }
                                ]
                                []
                            , text [ style { color = "black", fontWeight = "bold" } ] [ str "Unlock Screen?" ]
                            ]

                    _ ->
                        null
                , text [ style { fontSize = 14, fontWeight = "bold", marginTop = 5 } ] [ str "Screen Locked" ]
                , text [ style { fontSize = 11 } ] [ str "Tab to unlock" ]
                ]
            ]
        )


videoPlayerControls : VideoPlayer -> Html Msg
videoPlayerControls videoPlayer =
    if videoPlayer.showControls || videoPlayer.hidingControls then
        touchableWithoutFeedback
            [ onPress <| Decode.succeed <| ToggleVideoPlayerControls
            ]
            [ Animated.view
                [ style styles.fullscreen
                , style
                    { opacity = videoPlayer.playerControlsAnimatedValue
                    , backgroundColor = "#00000060"
                    }
                ]
                [ if videoPlayer.screenLock == Unlocked then
                    videoPlayerControlsHeader videoPlayer

                  else
                    null
                , if videoPlayer.screenLock == Unlocked then
                    videoPlayerControlsBody videoPlayer

                  else
                    null
                , Animated.view
                    [ style
                        { position = "absolute"
                        , width = "100%"
                        , bottom =
                            Animated.multiply (Animated.create -20)
                                (Animated.subtract (Animated.create 1) videoPlayer.playerControlsAnimatedValue)
                        }
                    ]
                    [ if videoPlayer.screenLock == Unlocked then
                        videoPlayerControlsProgress videoPlayer

                      else
                        null
                    , videoPlayerControlsFooter videoPlayer
                    ]
                ]
            ]

    else
        null


subtitleText : String -> Html msg
subtitleText s =
    view [ style styles.subtitleContainer ]
        [ text [ style styles.subtitle ] [ str s ] ]


videoPlayerSubtitle { subtitle, playbackTime, seeking, showSubtitle } =
    if seeking || not showSubtitle then
        null

    else
        let
            s =
                subtitle
                    |> List.filter (\dialogue -> dialogue.start <= playbackTime && playbackTime <= dialogue.end)
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
                , pointerEvents "none"
                ]
                [ lazy subtitleText s ]


handlePinch scale =
    VideoPlayerControl <|
        ChangeResizeMode <|
            if scale > 1 then
                "cover"

            else
                "contain"


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
                , resizeMode videoPlayer.resizeMode
                , playWhenInactive True
                , rate <| playbackSpeedToRate videoPlayer.playbackSpeed
                ]
                [ videoPlayerSubtitle videoPlayer
                , pinchableView [ onTap ToggleVideoPlayerControls, onPinch handlePinch, style styles.fullscreen ] []
                , videoPlayerControls videoPlayer
                , if videoPlayer.isBuffering && not videoPlayer.seeking then
                    activityIndicator [ style styles.center, stringSize "large" ] []

                  else
                    null
                ]
            , subtitleStream
                [ SubtitleStream.url <| getSubtitleUrl client screenMetrics videoPlayer.metadata.ratingKey videoPlayer.sessionId
                , SubtitleStream.playbackTime videoPlayer.subtitleSeekTime
                , SubtitleStream.onDialogues <| Decode.map GotSubtitle <| Decode.list dialogueDecoder
                ]
                []
            ]

    else
        null
