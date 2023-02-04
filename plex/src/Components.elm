module Components exposing (bottomPadding, chip, favicon, onPinch, onTap, pinchableView, progressBar, text, videoPlay, videoPlayContainer)

import Browser
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative exposing (image, node, require, str, text, touchableOpacity, touchableScale, view)
import ReactNative.Events exposing (on, onFloat, onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Properties exposing (color, name, property, size, source, style, zoomScale)
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
