module Components exposing (bottomPadding, chip, favicon, langSelect, loading, modalFadeView, onPinch, onTap, pinchableView, progressBar, smallLoading, text, videoPlay, videoPlayContainer)

import Browser
import Dict
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
    [ ( "af", "Afrikaans" )
    , ( "an", "Aragonés" )
    , ( "az", "Azərbaycan dili" )
    , ( "id", "Bahasa Indonesia" )
    , ( "ms", "Bahasa Melayu" )
    , ( "bn", "Bengali" )
    , ( "bs", "Bosanski jezik" )
    , ( "br", "Brezhoneg" )
    , ( "my", "Burmese" )
    , ( "ca", "Català" )
    , ( "cs", "Čeština" )
    , ( "da", "Dansk" )
    , ( "de", "Deutsch" )
    , ( "et", "Eesti" )
    , ( "es", "Español" )
    , ( "eo", "Esperanto" )
    , ( "eu", "Euskara" )
    , ( "fr", "Français" )
    , ( "gl", "Galego" )
    , ( "hr", "Hrvatski" )
    , ( "is", "Íslenska" )
    , ( "it", "Italiano" )
    , ( "km", "Khmer" )
    , ( "sw", "Kiswahili" )
    , ( "ku", "Kurdî" )
    , ( "lv", "Latviešu valoda" )
    , ( "lb", "Lëtzebuergesch" )
    , ( "lt", "Lietuvių kalba" )
    , ( "hu", "Magyar" )
    , ( "ml", "Malayalam" )
    , ( "nl", "Nederlands" )
    , ( "no", "Norsk" )
    , ( "oc", "Occitan" )
    , ( "pl", "Polski" )
    , ( "pt", "Português" )
    , ( "pt-BR", "Português Brasileiro" )
    , ( "ro", "Română" )
    , ( "sq", "Shqip" )
    , ( "si", "Sinhala" )
    , ( "sk", "Slovenčina" )
    , ( "sl", "Slovenščina" )
    , ( "fi", "Suomeksi" )
    , ( "sv", "Svenska" )
    , ( "te", "Telugu" )
    , ( "vi", "Tiếng Việt" )
    , ( "tr", "Türkçe" )
    , ( "tl", "Wikang Tagalog" )
    , ( "el", "Ελληνικά" )
    , ( "be", "Беларуская" )
    , ( "bg", "български език" )
    , ( "kk", "Қазақ тілі" )
    , ( "mk", "македонски јазик" )
    , ( "mn", "монгол" )
    , ( "ru", "русский язык" )
    , ( "sr", "српски језик" )
    , ( "uk", "українська" )
    , ( "ka", "ქართული" )
    , ( "hy", "Հայերեն" )

    --    ,("he", "עברית")
    --    ,("ur", "اردو")
    --    ,("ar", "العربية")
    --    ,("fa", "فارسی")
    , ( "hi", "हिन्दी" )
    , ( "ta", "தமிழ்" )
    , ( "kn", "ಕನ್ನಡ" )
    , ( "th", "ไทย" )
    , ( "ko", "한국어" )
    , ( "ja", "日本語" )
    , ( "en", "English" )
    , ( "zh", "中文" )
    , ( "zh-TW", "繁体中文" )
    ]


langTitles =
    Dict.fromList langs


langSelect : String -> (String -> msg) -> Html msg
langSelect selected onSelect =
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map (\{ actionKey } -> onSelect actionKey)
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , menuConfig
            { menuTitle = "Language"
            , menuItems =
                List.map
                    (\( actionKey, actionTitle ) ->
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
        [ touchableOpacity
            [ style
                { padding = 10
                , backgroundColor = "black"
                , borderRadius = 4
                }
            ]
            [ text
                [ style { fontWeight = "bold" } ]
                [ str <| Maybe.withDefault "" <| Dict.get selected langTitles ]
            ]
        ]
