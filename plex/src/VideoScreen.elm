module VideoScreen exposing (videoScreen)

import Api exposing (videoUri)
import Client exposing (Client)
import Components exposing (onPinch, onTap, pinchableView, text)
import Dto exposing (MediaStream, Metadata, dialogueDecoder)
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Maybe
import Model exposing (HomeModel, HomeMsg(..), PlaybackSpeed, PlaybackState(..), ScreenLockState(..), SearchSubtitle, SeekStage(..), VideoPlayer, VideoPlayerControlAction(..), episodeTitle, filterMediaStream, getFirstPartId, getSelectedSubtitleStream, isVideoUrlReady, playbackSpeedDecoder, playbackSpeedEncode, playbackSpeedList, playbackSpeedToRate)
import ReactNative exposing (activityIndicator, button, fragment, image, null, require, str, touchableOpacity, touchableScale, touchableWithoutFeedback, view)
import ReactNative.Animated as Animated
import ReactNative.ContextMenuIOS exposing (MenuItem, contextMenuButton, isMenuPrimaryAction, menuConfig, onPressMenuItem, pressEventMenuItemDecoder)
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import ReactNative.Events exposing (onFloatValueChange, onPress)
import ReactNative.Icon exposing (ionicon, materialIcon)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (animationType, color, disabled, intValue, presentationStyle, resizeMode, size, source, stringSize, style, supportedOrientations, title, transparent, visible)
import ReactNative.StyleSheet as StyleSheet
import Theme
import Time
import Utils exposing (containsItem, formatPlaybackTime)
import Video.Episodes exposing (episodesView)
import Video.ProgressBar exposing (videoPlayerControlsProgress)
import Video.SearchSubtitle exposing (searchSubtitleView)
import Video.Subtitle exposing (videoPlayerSubtitle)
import Video.SubtitleStream as SubtitleStream exposing (subtitleStream)
import Video.VideoView exposing (onBuffering, onEnded, onError, onPlaying, onProgress, paused, rate, seek, src, video)


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


videoPlayerControlsHeader : VideoPlayer -> Html HomeMsg
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


videoPlayerControlsBody : VideoPlayer -> Html HomeMsg
videoPlayerControlsBody videoPlayer =
    view
        [ style
            { position = "absolute"
            , top = "50%"
            , left = "30%"
            , height = 60
            , marginTop = -30
            , width = "40%"
            , marginHorizontal = "auto"
            , flexDirection = "row"
            , justifyContent = "space-between"
            , alignItems = "center"
            }
        ]
        [ videoPlayerControlsPressableImageIcon 35 (require "./assets/backward.png") "" <| VideoPlayerControl <| SeekAction SeekRelease (max 0 <| videoPlayer.playbackTime - 10 * 1000)
        , if videoPlayer.state == Playing then
            videoPlayerControlsIcon 55 "pause" <| VideoPlayerControl TogglePlay

          else
            videoPlayerControlsIcon 55 "play" <| VideoPlayerControl TogglePlay
        , videoPlayerControlsPressableImageIcon 35 (require "./assets/forward.png") "" <| VideoPlayerControl <| SeekAction SeekRelease (min videoPlayer.metadata.duration <| videoPlayer.playbackTime + 10 * 1000)
        ]


playbackSpeedMenu : PlaybackSpeed -> Html HomeMsg
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
                            , attributes = Nothing
                            }
                        )
            }
        ]
        [ let
            label =
                "Speed (" ++ playbackSpeedEncode playbackSpeed ++ ")"
          in
          videoPlayerControlsFooterButton (require "./assets/speed.png") label <| VideoPlayerControl ExtendTimeout
        ]


subtitleMenu : VideoPlayer -> Html HomeMsg
subtitleMenu { metadata, showSubtitle, selectedSubtitle } =
    let
        partId =
            Maybe.withDefault 0 <| getFirstPartId metadata

        subs =
            metadata
                |> filterMediaStream (\{ streamType, codec } -> streamType == 3)
                |> List.map
                    (\{ id, displayTitle, selected } ->
                        { id = id
                        , label = displayTitle
                        }
                    )
                |> appendOffItem

        appendOffItem menus =
            menus ++ [ { id = 0, label = "Off" } ]

        haveSubtitle =
            List.length subs > 1

        searchSubtitleMenuItem =
            { actionKey = "search"
            , actionTitle = "    Search"
            , attributes = Nothing
            }
    in
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map
                (\{ actionKey } ->
                    case actionKey of
                        "search" ->
                            VideoPlayerControl <| SetSearchSubtitleOpen True

                        _ ->
                            VideoPlayerControl <| ChangeSubtitle partId <| Maybe.withDefault 0 <| String.toInt actionKey
                )
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , menuConfig
            { menuTitle = ""
            , menuItems =
                if haveSubtitle then
                    searchSubtitleMenuItem
                        :: List.map
                            (\{ id, label } ->
                                { actionKey = String.fromInt id
                                , actionTitle =
                                    if id == selectedSubtitle then
                                        "✓ " ++ label

                                    else
                                        "    " ++ label
                                , attributes = Nothing
                                }
                            )
                            subs

                else
                    [ searchSubtitleMenuItem ]
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
                        , disabled True
                        ]
                   )
            )
        ]


screenLocked videoPlayer =
    touchableOpacity
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


videoPlayerControlsFooter : VideoPlayer -> Html HomeMsg
videoPlayerControlsFooter videoPlayer =
    Animated.view
        [ style
            { position = "absolute"
            , width = "100%"
            , bottom =
                Animated.multiply (Animated.create -20)
                    (Animated.subtract (Animated.create 1) videoPlayer.playerControlsAnimatedValue)
            , justifyContent = "center"
            , flexDirection = "column"
            }
        ]
        [ if videoPlayer.screenLock == Unlocked then
            videoPlayerControlsProgress videoPlayer

          else
            null
        , videoPlayerControlsToolbar videoPlayer
        ]


videoPlayerControlsToolbar : VideoPlayer -> Html HomeMsg
videoPlayerControlsToolbar videoPlayer =
    view
        [ style
            { flexDirection = "row"
            , justifyContent =
                "center"
            , height =
                if videoPlayer.screenLock == Unlocked then
                    50

                else
                    80
            , alignItems = "flex-start"
            , gap = 20
            }
        ]
        (if videoPlayer.screenLock == Unlocked then
            [ playbackSpeedMenu videoPlayer.playbackSpeed
            , videoPlayerControlsFooterButton (require "./assets/lock-open.png") "Lock" <| VideoPlayerControl <| ChangeScreenLock Locked
            , if videoPlayer.metadata.typ == "movie" then
                null

              else
                videoPlayerControlsFooterButton (require "./assets/episodes.png") "Episodes" <| VideoPlayerControl <| SetEpisodesOpen True
            , subtitleMenu videoPlayer
            , if videoPlayer.metadata.typ == "episode" then
                videoPlayerControlsFooterButton (require "./assets/next-ep.png") "Next Ep." <| VideoPlayerControl NextEpisode

              else
                null
            ]

         else
            [ screenLocked videoPlayer ]
        )


videoPlayerControls : VideoPlayer -> Html HomeMsg
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
                , videoPlayerControlsFooter videoPlayer
                ]
            ]

    else
        null


handlePinch isUnlocked scale =
    if isUnlocked then
        VideoPlayerControl <|
            ChangeResizeMode <|
                if scale > 1 then
                    "cover"

                else
                    "contain"

    else
        HomeNoOp


bufferingIndicator videoPlayer =
    if videoPlayer.isBuffering && not videoPlayer.seeking then
        activityIndicator [ style styles.center, stringSize "large" ] []

    else
        null


pinchResizer videoPlayer =
    pinchableView
        [ onTap ToggleVideoPlayerControls
        , onPinch <| handlePinch <| videoPlayer.screenLock == Unlocked
        , style styles.fullscreen
        ]
        []


getVideoFileName : Metadata -> String
getVideoFileName metadata =
    case metadata.medias of
        media :: _ ->
            case media.parts of
                part :: _ ->
                    Utils.getFileName part.file

                _ ->
                    ""

        _ ->
            ""


videoScreen : HomeModel -> () -> Html HomeMsg
videoScreen ({ videoPlayer, client } as m) _ =
    if isVideoUrlReady videoPlayer then
        view [ style styles.container ]
            [ video
                [ src <| videoUri videoPlayer.session videoPlayer.sessionId videoPlayer.metadata client
                , seek (toFloat videoPlayer.seekTime / toFloat videoPlayer.metadata.duration)
                , onError <| Decode.succeed <| PlayVideoError "Unexpected error occurred"
                , onEnded <| Decode.succeed OnVideoEnd
                , onBuffering <| Decode.succeed <| OnVideoBuffer True
                , onPlaying <| Decode.succeed <| OnVideoBuffer False
                , onProgress (\p -> OnVideoProgress p.currentTime)
                , paused <| (videoPlayer.state /= Playing || videoPlayer.seeking || videoPlayer.episodesOpen || videoPlayer.searchSubtitle.open)
                , rate <| playbackSpeedToRate videoPlayer.playbackSpeed
                , style styles.fullscreen
                , resizeMode videoPlayer.resizeMode
                ]
                []
            , if videoPlayer.selectedSubtitle == 0 then
                null

              else
                videoPlayerSubtitle client videoPlayer
            , pinchResizer videoPlayer
            , videoPlayerControls videoPlayer
            , bufferingIndicator videoPlayer
            , episodesView m
            , searchSubtitleView (getVideoFileName videoPlayer.metadata) videoPlayer.searchSubtitle
            ]

    else
        null



-- Utils


videoPlayerControlsIcon sz name pressMsg =
    touchableScale [ onPress <| Decode.succeed <| pressMsg ]
        [ ionicon name [ size sz, color "white" ]
        ]


videoPlayerControlsImageIcon sz src label props =
    touchableScale
        (style { flexDirection = "row", gap = 4, alignItems = "center" } :: props)
        [ image
            [ source src
            , style { width = sz, height = sz }
            ]
            []
        , if String.isEmpty label then
            null

          else
            text [ style { fontSize = 13, fontWeight = "bold" } ] [ str label ]
        ]


videoPlayerControlsPressableImageIcon sz src label msg =
    videoPlayerControlsImageIcon sz src label <| [ onPress <| Decode.succeed msg ]


videoPlayerControlsFooterButton =
    videoPlayerControlsPressableImageIcon 17
