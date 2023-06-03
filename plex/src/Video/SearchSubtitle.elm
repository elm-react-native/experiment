module Video.SearchSubtitle exposing (searchSubtitleView)

import Components exposing (langSelect, loading, modalFadeView, smallLoading, text)
import Dto exposing (MediaStream)
import Html exposing (Html)
import Json.Decode as Decode
import Model exposing (Msg(..), SearchSubtitle, VideoPlayerControlAction(..))
import ReactNative exposing (str, textInput, touchableOpacity, touchableScale, view)
import ReactNative.BlurView exposing (blurAmount, blurType, blurView)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Properties exposing (color, contentContainerStyle, placeholder, placeholderTextColor, readonly, size, style, visible)
import ReactNative.StyleSheet as StyleSheet
import ReactNative.TextInput exposing (onEndEditing, returnKeyType)
import Set exposing (Set)
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
        , input =
            { borderBottomWidth = StyleSheet.hairlineWidth
            , fontFamily = Theme.fontFamily
            , height = 44
            , width = "80%"
            , marginTop = 20
            , color = "white"
            , borderColor = Theme.themeColor
            }
        , subtitles =
            { gap = 15
            , alignItems = "flex-start"
            , justifyContent = "flex-start"
            , flex = 1
            , width = "80%"
            }
        , subtitle =
            { justifyContent = "space-between"
            , alignItems = "center"
            , flexDirection = "row"
            , width = "100%"
            }
        }


searchResultItem : Set String -> MediaStream -> Html Msg
searchResultItem downloadings { key, extendedDisplayTitle } =
    touchableOpacity
        [ style styles.subtitle, onPress (Decode.succeed <| VideoPlayerControl <| ApplySubtitle key) ]
        [ text [] [ str extendedDisplayTitle ]
        , if Set.member key downloadings then
            smallLoading

          else
            ionicon "download" [ size 16, color "white" ]
        ]


close : Html Msg
close =
    view
        [ style { position = "absolute", right = 35, top = 25 } ]
        [ touchableScale [ onPress <| Decode.succeed <| VideoPlayerControl <| SetSearchSubtitleOpen False ]
            [ ionicon "ios-close" [ color "white", size 25 ]
            ]
        ]


searchSubtitleView : String -> SearchSubtitle -> Html Msg
searchSubtitleView defaultTitle { language, items, open, downloadings } =
    modalFadeView
        [ style styles.container
        , visible open
        , blurType "dark"
        , blurAmount 60
        , contentContainerStyle styles.fullScreen
        ]
    <|
        [ close
        , langSelect language (VideoPlayerControl << ChangeSearchSubtitleLanguage)
        , textInput
            [ style styles.input
            , placeholder defaultTitle
            , placeholderTextColor Theme.inputPlaceholderColor
            , returnKeyType "search"
            , readonly (items == Nothing)
            , onEndEditing
                (Decode.map (VideoPlayerControl << SendSearchSubtitle)
                    (Decode.at [ "nativeEvent", "text" ] Decode.string)
                )
            ]
            []
        , case items of
            Just (Ok subs) ->
                view [ style styles.subtitles ] (List.map (searchResultItem downloadings) subs)

            Just (Err _) ->
                view [ style { alignItems = "center" } ] [ text [] [ str "Search Failed" ] ]

            _ ->
                view [ style { alignItems = "center" } ] [ loading ]
        ]
