module Components exposing (bottomPadding, chip, favicon, loading, modalFadeView, onPinch, onTap, pinchableView, progressBar, text, videoPlay, videoPlayContainer)

import Browser
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative exposing (activityIndicator, image, node, require, str, text, touchableOpacity, touchableScale, view)
import ReactNative.Events exposing (on, onFloat, onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Picker exposing (label, onValueChange, picker, pickerItem, selectedValue)
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


langs =
    [ "Afrikaans"
    , "Aragonés"
    , "Azərbaycan dili"
    , "Bahasa Indonesia"
    , "Bahasa Melayu"
    , "Bengali"
    , "Bosanski jezik"
    , "Brezhoneg"
    , "Burmese"
    , "Català"
    , "Čeština"
    , "Dansk"
    , "Deutsch"
    , "Eesti"
    , "English"
    , "Español"
    , "Esperanto"
    , "Euskara"
    , "Français"
    , "Galego"
    , "Hrvatski"
    , "Íslenska"
    , "Italiano"
    , "Khmer"
    , "Kiswahili"
    , "Kurdî"
    , "Latviešu valoda"
    , "Lëtzebuergesch"
    , "Lietuvių kalba"
    , "Magyar"
    , "Malayalam"
    , "Nederlands"
    , "Norsk"
    , "Occitan"
    , "Polski"
    , "Português"
    , "Português Brasileiro"
    , "Română"
    , "Shqip"
    , "Sinhala"
    , "Slovenčina"
    , "Slovenščina"
    , "Suomeksi"
    , "Svenska"
    , "Telugu"
    , "Tiếng Việt"
    , "Türkçe"
    , "Wikang Tagalog"
    , "Ελληνικά"
    , "Беларуская"
    , "български език"
    , "Қазақ тілі"
    , "македонски јазик"
    , "монгол"
    , "русский язык"
    , "српски језик"
    , "українська"
    , "ქართული"
    , "Հայերեն"
    , "עברית"
    , "اردو"
    , "العربية"
    , "فارسی"
    , "हिन्दी"
    , "தமிழ்"
    , "ಕನ್ನಡ"
    , "ไทย"
    , "한국어"
    , "中文"
    , "日本語"
    , "臺語"
    ]


langSelect : String -> (String -> msg) -> Html msg
langSelect selected onSelect =
    picker [ selectedValue selected, onValueChange (\{ item } -> onSelect item) ] <|
        List.map (\lang -> pickerItem [ label lang, stringValue lang ] []) langs
