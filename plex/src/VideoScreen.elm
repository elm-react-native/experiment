module VideoScreen exposing (videoScreen)

import Api
import Components exposing (text)
import EntityScreen exposing (episodeTitle)
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, Msg(..), VideoPlayer, isVideoUrlReady)
import ReactNative exposing (activityIndicator, button, fragment, image, null, require, str, touchableOpacity, touchableWithoutFeedback, view)
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import ReactNative.Events exposing (onFloatValueChange, onPress)
import ReactNative.Icon exposing (ionicon, materialIcon)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (color, component, componentModel, getId, intValue, name, options, size, source, stringSize, style, title)
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
        }


videoTitle metadata =
    case metadata.typ of
        "episode" ->
            episodeTitle metadata

        _ ->
            metadata.title


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


videoPlayerControlsImageIcon sz src pressMsg =
    touchableOpacity
        [ onPress <| Decode.succeed <| pressMsg ]
        [ image
            [ source src
            , style { width = sz, height = sz }
            ]
            []
        ]


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
                { display =
                    if videoPlayer.seeking then
                        "none"

                    else
                        "flex"
                , flexDirection = "row"
                , gap = 110
                , justifyContent = "center"
                , alignItems = "center"
                , flexGrow = 1
                }
            ]
            [ videoPlayerControlsImageIcon 35 (require "./assets/backward.png") <| ChangeSeeking False (max 0 <| videoPlayer.playbackTime - 10 * 1000)
            , if videoPlayer.playing then
                videoPlayerControlsIcon 55 "pause" <| ChangePlaying False

              else
                videoPlayerControlsIcon 55 "play" <| ChangePlaying True
            , videoPlayerControlsImageIcon 35 (require "./assets/forward.png") <| ChangeSeeking False (min videoPlayer.metadata.duration <| videoPlayer.playbackTime + 10 * 1000)
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
            , onFloatValueChange <| round >> OnVideoSeek
            , onSlidingStart <| round >> ChangeSeeking True
            , onSlidingComplete <| round >> ChangeSeeking False
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
        [ view [ style { flexDirection = "row", gap = 3, alignItems = "center" } ]
            [ videoPlayerControlsImageIcon 25 (require "./assets/speed.png") NoOp
            , text [ style { fontSize = 12, fontWeight = "bold" } ] [ str "Speed (1x)" ]
            ]
        , view [ style { flexDirection = "row", gap = 3, alignItems = "center" } ]
            [ videoPlayerControlsImageIcon 25 (require "./assets/speed.png") NoOp
            , text [ style { fontSize = 12, fontWeight = "bold" } ] [ str "Lock" ]
            ]
        , view [ style { flexDirection = "row", gap = 3, alignItems = "center" } ]
            [ videoPlayerControlsImageIcon 25 (require "./assets/speed.png") NoOp
            , text [ style { fontSize = 12, fontWeight = "bold" } ] [ str "Episodes" ]
            ]
        , view [ style { flexDirection = "row", gap = 3, alignItems = "center" } ]
            [ videoPlayerControlsImageIcon 25 (require "./assets/subtitle.png") NoOp
            , text [ style { fontSize = 12, fontWeight = "bold" } ] [ str "Subtitles" ]
            ]
        , view [ style { flexDirection = "row", gap = 3, alignItems = "center" } ]
            [ videoPlayerControlsImageIcon 25 (require "./assets/subtitle.png") NoOp
            , text [ style { fontSize = 12, fontWeight = "bold" } ] [ str "Next Episode" ]
            ]
        ]


videoPlayerControls videoPlayer =
    view
        [ style styles.fullscreen
        , style
            { display =
                if videoPlayer.showControls || videoPlayer.seeking then
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
    view
        [ style
            { backgroundColor = "#000000c0"
            , alignItems = "center"
            , justifyContent = "center"
            , paddingHorizontal = 5
            , paddingVertical = 3
            , width = "auto"
            }
        ]
        [ text [ style { fontSize = 18 } ] [ str s ] ]


videoPlayerSubtitle { subtitle, playbackTime, seeking } =
    if seeking then
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
                    }
                , style { alignItems = "center" }
                ]
                [ lazy subtitleText s ]


videoScreen : HomeModel -> () -> Html Msg
videoScreen ({ videoPlayer, screenMetrics, client } as m) _ =
    if isVideoUrlReady videoPlayer then
        view [ style styles.container ]
            [ video
                [ source { uri = videoUri screenMetrics videoPlayer client }
                , playWhenInactive True
                , pictureInPicture True
                , seekTime videoPlayer.seekTime
                , onErrorMessage PlayVideoError
                , onEnd <| Decode.succeed OnVideoEnd
                , onBuffer OnVideoBuffer
                , onProgress (\p -> OnVideoProgress p.currentTime)
                , onSeek <| Decode.succeed OnVideoSeeked
                , style styles.fullscreen
                , allowsExternalPlayback False
                , paused <| (not videoPlayer.playing || videoPlayer.seeking)
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
