module Components exposing (..)

import Html exposing (Html)
import Json.Decode exposing (Decoder)
import ReactNative exposing (image, ionicon, require, touchableOpacity, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (color, size, source, style)
import Theme
import Utils exposing (percentFloat)


videoPlay : Decoder msg -> Html msg
videoPlay handlePress =
    view
        [ style
            { backgroundColor = "rgba(0,0,0,0.6)"
            , borderRadius = 15
            , borderColor = "white"
            , borderWidth = 1
            }
        ]
        [ touchableOpacity
            [ onPress handlePress
            , style
                { width = 28
                , height = 28
                , justifyContent = "center"
                , alignItems = "center"
                , left = 1
                }
            ]
            [ ionicon "play" [ color "white", size 15 ] ]
        ]


vidoePlayContainer : Decoder msg -> Html msg
vidoePlayContainer handlePress =
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
        [ videoPlay handlePress ]


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
