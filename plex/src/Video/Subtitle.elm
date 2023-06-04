module Video.Subtitle exposing (..)

import Api exposing (getSubtitleUrl)
import Browser
import Components exposing (text)
import Dto exposing (dialogueDecoder)
import Html exposing (Attribute, Html)
import Html.Lazy exposing (lazy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Model exposing (HomeMsg(..))
import ReactNative exposing (fragment, null, str, view)
import ReactNative.Platform as Platform
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
        , subtitle =
            { fontSize =
                if Platform.isPad then
                    22

                else
                    18
            }
        }


subtitleText : String -> Html msg
subtitleText s =
    view [ style styles.subtitleContainer ]
        [ text [ style styles.subtitle ] [ str s ] ]


videoPlayerSubtitle client { subtitle, subtitleSeekTime, playbackTime, seeking, showSubtitle, metadata, session, sessionId, selectedSubtitle } =
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
            [ SubtitleStream.url <| getSubtitleUrl client metadata.ratingKey session sessionId
            , SubtitleStream.playbackTime subtitleSeekTime
            , SubtitleStream.subtitleStreamId <| selectedSubtitle
            , SubtitleStream.onDialogues <| Decode.map GotSubtitle <| Decode.list dialogueDecoder
            ]
            []
        ]
