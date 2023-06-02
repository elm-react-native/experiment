module Video.SearchSubtitle exposing (searchSubtitleView)

import Components exposing (modalFadeView)
import Dto exposing (MediaStream)
import Html exposing (Html)
import Json.Decode as Decode
import Model exposing (Msg(..), SearchSubtitle, VideoPlayerControlAction(..))
import ReactNative exposing (str, text, textInput, touchableScale, view)
import ReactNative.BlurView exposing (blurAmount, blurType, blurView)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Properties exposing (color, contentContainerStyle, placeholder, placeholderTextColor, size, style, visible)
import ReactNative.StyleSheet as StyleSheet
import Theme


styles =
    StyleSheet.create
        { fullScreen =
            { position = "absolute"
            , left = 0
            , top = 0
            , right = 0
            , bottom = 0
            }
        , container =
            { gap = 15
            , alignItems = "center"
            , justifyContent = "flex-start"
            , flex = 1
            }
        , subtitleName = { color = "white" }
        , subtitles =
            { gap = 15
            , alignItems = "flex-start"
            , justifyContent = "flex-start"
            , flex = 1
            , width = "80%"
            }
        , input =
            { borderBottomWidth = StyleSheet.hairlineWidth
            , fontFamily = Theme.fontFamily
            , height = 44
            , width = "80%"
            , marginTop = 20
            , color = "white"
            , borderColor = Theme.themeColor
            }
        }


searchResultItem : MediaStream -> Html msg
searchResultItem { extendedDisplayTitle } =
    view []
        [ text [ style styles.subtitleName ] [ str extendedDisplayTitle ]
        ]


close : Html Msg
close =
    view
        [ style { position = "absolute", right = 35, top = 25 } ]
        [ touchableScale [ onPress <| Decode.succeed <| VideoPlayerControl <| SetSearchSubtitleOpen False ]
            [ ionicon "ios-close"
                [ color "white"
                , size 25
                ]
            ]
        ]


searchSubtitleView : String -> SearchSubtitle -> Html Msg
searchSubtitleView defaultTitle { items, open } =
    modalFadeView
        [ style styles.container
        , visible open
        , blurType "dark"
        , blurAmount 60
        , contentContainerStyle styles.fullScreen
        ]
    <|
        case items of
            Just (Ok subs) ->
                [ close
                , textInput
                    [ style styles.input
                    , placeholder defaultTitle
                    , placeholderTextColor "#555"
                    ]
                    []
                , view [ style styles.subtitles ] (List.map searchResultItem subs)
                ]

            Just (Err _) ->
                [ text [] [ str "Failed" ]
                , close
                ]

            _ ->
                [ text [] [ str "Loading..." ]
                , close
                ]
