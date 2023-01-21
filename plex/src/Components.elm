module Components exposing (bottomPadding, chip, favicon, progressBar, videoPlay, videoPlayContainer)

import Browser
import Html exposing (Attribute, Html)
import Json.Decode exposing (Decoder)
import ReactNative exposing (image, node, require, str, text, touchableOpacity, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Properties exposing (color, name, size, source, style)
import Theme
import Utils exposing (percentFloat)


videoPlay : Int -> Decoder msg -> Html msg
videoPlay iconSize handlePress =
    view
        [ style
            { backgroundColor = "rgba(0,0,0,0.6)"
            , borderRadius = iconSize
            , borderColor = "white"
            , borderWidth = 1
            }
        ]
        [ touchableOpacity
            [ onPress handlePress
            , style
                { width = iconSize * 2 - 2
                , height = iconSize * 2 - 2
                , justifyContent = "center"
                , alignItems = "center"
                , left = toFloat iconSize / 15
                }
            ]
            [ ionicon "play" [ color "white", size iconSize ] ]
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
                { color = "white"
                , fontSize = 8
                , fontWeight = "bold"
                }
            ]
            [ str label ]
        ]
