module Components exposing (bottomPadding, chip, favicon, langSelect, loading, modalFadeView, onPinch, onTap, pinchableView, progressBar, smallLoading, text, videoPlay, videoPlayContainer)

import Browser
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative exposing (activityIndicator, image, node, require, str, text, touchableOpacity, touchableScale, view)
import ReactNative.ContextMenuIOS exposing (MenuItem, contextMenuButton, isMenuPrimaryAction, menuConfig, onPressMenuItem, pressEventMenuItemDecoder)
import ReactNative.Events exposing (on, onFloat, onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Properties exposing (color, name, property, size, source, stringSize, stringValue, style, zoomScale)
import Theme
import Utils exposing (percentFloat)


pinchableView =
    node "PinchableView"


onPinch =
    onFloat "pinch"


onTap msg =
    on "tap" <| Decode.succeed msg


text props children =
    ReactNative.text (style { color = "white", fontFamily = Theme.fontFamily } :: props) children


videoPlay : Int -> Decoder msg -> Html msg
videoPlay size handlePress =
    touchableScale
        [ onPress handlePress
        , style
            { borderRadius = size
            , backgroundColor = "rgba(0,0,0,0.6)"
            , overflow = "hidden"
            , borderWidth = 1
            , borderColor = "white"
            }
        ]
        [ image
            [ source <| require "./assets/play.png"
            , style
                { width = size
                , height = size
                }
            ]
            []
        ]


modalFadeView =
    node "ModalFadeView"


videoPlayContainer : Int -> Decoder msg -> Html msg
videoPlayContainer iconSize handlePress =
    view
        [ style
            { position = "absolute"
            , left = 0
            , top = 0
            , right = 0
            , bottom = 0
            , alignItems = "center"
            , justifyContent = "center"
            }
        ]
        [ videoPlay iconSize handlePress ]


progressBar : List (Html.Attribute msg) -> Float -> Html msg
progressBar props p =
    view
        (style
            { backgroundColor = "gray"
            , height = 3
            }
            :: props
        )
        [ view
            [ style
                { width = percentFloat p
                , backgroundColor = Theme.themeColor
                , height = "100%"
                }
            ]
            []
        ]


favicon : a -> Html msg
favicon size =
    image
        [ source <| require "./assets/plex-favicon.png"
        , style { width = size, height = size }
        ]
        []


bottomPadding : Html msg
bottomPadding =
    view [ style { height = 70, width = "100%" } ] []


chip : String -> Html msg
chip label =
    view
        [ style
            { backgroundColor = "gray"
            , borderRadius = 2
            , padding = 2
            , marginLeft = 2
            , alignItems = "center"
            , justifyContent = "center"
            }
        ]
        [ text
            [ style
                { fontSize = 8
                , fontWeight = "bold"
                }
            ]
            [ str label ]
        ]


loading =
    activityIndicator [ stringSize "large" ] []


smallLoading =
    activityIndicator [ stringSize "small" ] []


langs =
    [ { actionKey = "af", actionTitle = "Afrikaans" }
    , { actionKey = "an", actionTitle = "Aragonés" }
    , { actionKey = "az", actionTitle = "Azərbaycan dili" }
    , { actionKey = "id", actionTitle = "Bahasa Indonesia" }
    , { actionKey = "ms", actionTitle = "Bahasa Melayu" }
    , { actionKey = "bn", actionTitle = "Bengali" }
    , { actionKey = "bs", actionTitle = "Bosanski jezik" }
    , { actionKey = "br", actionTitle = "Brezhoneg" }
    , { actionKey = "my", actionTitle = "Burmese" }
    , { actionKey = "ca", actionTitle = "Català" }
    , { actionKey = "cs", actionTitle = "Čeština" }
    , { actionKey = "da", actionTitle = "Dansk" }
    , { actionKey = "de", actionTitle = "Deutsch" }
    , { actionKey = "et", actionTitle = "Eesti" }
    , { actionKey = "es", actionTitle = "Español" }
    , { actionKey = "eo", actionTitle = "Esperanto" }
    , { actionKey = "eu", actionTitle = "Euskara" }
    , { actionKey = "fr", actionTitle = "Français" }
    , { actionKey = "gl", actionTitle = "Galego" }
    , { actionKey = "hr", actionTitle = "Hrvatski" }
    , { actionKey = "is", actionTitle = "Íslenska" }
    , { actionKey = "it", actionTitle = "Italiano" }
    , { actionKey = "km", actionTitle = "Khmer" }
    , { actionKey = "sw", actionTitle = "Kiswahili" }
    , { actionKey = "ku", actionTitle = "Kurdî" }
    , { actionKey = "lv", actionTitle = "Latviešu valoda" }
    , { actionKey = "lb", actionTitle = "Lëtzebuergesch" }
    , { actionKey = "lt", actionTitle = "Lietuvių kalba" }
    , { actionKey = "hu", actionTitle = "Magyar" }
    , { actionKey = "ml", actionTitle = "Malayalam" }
    , { actionKey = "nl", actionTitle = "Nederlands" }
    , { actionKey = "no", actionTitle = "Norsk" }
    , { actionKey = "oc", actionTitle = "Occitan" }
    , { actionKey = "pl", actionTitle = "Polski" }
    , { actionKey = "pt", actionTitle = "Português" }
    , { actionKey = "pt-BR", actionTitle = "Português Brasileiro" }
    , { actionKey = "ro", actionTitle = "Română" }
    , { actionKey = "sq", actionTitle = "Shqip" }
    , { actionKey = "si", actionTitle = "Sinhala" }
    , { actionKey = "sk", actionTitle = "Slovenčina" }
    , { actionKey = "sl", actionTitle = "Slovenščina" }
    , { actionKey = "fi", actionTitle = "Suomeksi" }
    , { actionKey = "sv", actionTitle = "Svenska" }
    , { actionKey = "te", actionTitle = "Telugu" }
    , { actionKey = "vi", actionTitle = "Tiếng Việt" }
    , { actionKey = "tr", actionTitle = "Türkçe" }
    , { actionKey = "tl", actionTitle = "Wikang Tagalog" }
    , { actionKey = "el", actionTitle = "Ελληνικά" }
    , { actionKey = "be", actionTitle = "Беларуская" }
    , { actionKey = "bg", actionTitle = "български език" }
    , { actionKey = "kk", actionTitle = "Қазақ тілі" }
    , { actionKey = "mk", actionTitle = "македонски јазик" }
    , { actionKey = "mn", actionTitle = "монгол" }
    , { actionKey = "ru", actionTitle = "русский язык" }
    , { actionKey = "sr", actionTitle = "српски језик" }
    , { actionKey = "uk", actionTitle = "українська" }
    , { actionKey = "ka", actionTitle = "ქართული" }
    , { actionKey = "hy", actionTitle = "Հայերեն" }

    --    , { actionKey = "he", actionTitle = "עברית" }
    --    , { actionKey = "ur", actionTitle = "اردو" }
    --    , { actionKey = "ar", actionTitle = "العربية" }
    --    , { actionKey = "fa", actionTitle = "فارسی" }
    , { actionKey = "hi", actionTitle = "हिन्दी" }
    , { actionKey = "ta", actionTitle = "தமிழ்" }
    , { actionKey = "kn", actionTitle = "ಕನ್ನಡ" }
    , { actionKey = "th", actionTitle = "ไทย" }
    , { actionKey = "ko", actionTitle = "한국어" }
    , { actionKey = "ja", actionTitle = "日本語" }
    , { actionKey = "en", actionTitle = "English" }
    , { actionKey = "zh", actionTitle = "中文" }
    , { actionKey = "zh-TW", actionTitle = "繁体中文" }
    ]


langSelect : String -> (String -> msg) -> Html msg
langSelect selected onSelect =
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map (\{ actionKey } -> onSelect actionKey)
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , menuConfig
            { menuTitle = ""
            , menuItems =
                List.map
                    (\{ actionKey, actionTitle } ->
                        { actionKey = actionKey
                        , actionTitle =
                            if actionKey == selected then
                                "✓ " ++ actionTitle

                            else
                                "    " ++ actionTitle
                        , attributes = Nothing
                        }
                    )
                    langs
            }
        ]
        [ text [] [ str selected ] ]
