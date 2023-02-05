module Video.Subtitle exposing (..)

import Api
import Browser
import Components exposing (text)
import Html exposing (Attribute, Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Model exposing (Msg(..), dialogueDecoder)
import ReactNative exposing (fragment, null, str, view)
import ReactNative.Properties exposing (pointerEvents, style)
import ReactNative.StyleSheet as StyleSheet
import Video.SubtitleStream as SubtitleStream exposing (subtitleStream)


styles =
    StyleSheet.create
        { subtitleContainer =
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


subtitleText : String -> Html msg
subtitleText s =
    view [ style styles.subtitleContainer ]
        [ text [ style styles.subtitle ] [ str s ] ]


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


videoPlayerSubtitle client screenMetrics { subtitle, subtitleSeekTime, playbackTime, seeking, showSubtitle, metadata, sessionId } =
    fragment []
        [ if seeking || not showSubtitle then
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
        , subtitleStream
            [ SubtitleStream.url <| getSubtitleUrl client screenMetrics metadata.ratingKey sessionId
            , SubtitleStream.playbackTime subtitleSeekTime
            , SubtitleStream.onDialogues <| Decode.map GotSubtitle <| Decode.list dialogueDecoder
            ]
            []
        ]
