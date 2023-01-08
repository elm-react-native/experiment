module HomeScreen exposing (..)

import Api exposing (Client, Metadata, Section)
import Components exposing (vidoePlayContainer)
import Html exposing (Html)
import Json.Decode as Decode
import Model exposing (..)
import ReactNative
    exposing
        ( activityIndicator
        , button
        , image
        , imageBackground
        , ionicon
        , null
        , require
        , scrollView
        , str
        , text
        , touchableOpacity
        , view
        )
import ReactNative.Events exposing (onPress)
import ReactNative.Properties
    exposing
        ( color
        , contentContainerStyle
        , horizontal
        , imageStyle
        , persistentScrollbar
        , showsHorizontalScrollIndicator
        , size
        , source
        , style
        , title
        )
import ReactNative.StyleSheet as StyleSheet
import Theme
import Utils exposing (formatDuration, percentFloat)


homeStyles =
    StyleSheet.create
        { loading =
            { alignItems = "center"
            , justifyContent = "center"
            , height = "100%"
            , width = "100%"
            , backgroundColor = Theme.backgroundColor
            }
        , loadErrorText = { fontSize = 15, color = "white" }
        , container = { height = "100%", backgroundColor = Theme.backgroundColor }
        , sectionContainer =
            { height = 180, paddingVertical = 5 }
        , sectionTitle =
            { fontSize = 15
            , fontWeight = "bold"
            , color = "white"
            , marginLeft = 5
            , marginBottom = 4
            }
        , sectionContent =
            { flexDirection = "row"
            , alignItems = "center"
            , justifyContent = "center"
            }
        , sectionContentLoading =
            { width = "100%" }
        , itemContainer =
            { marginHorizontal = 5
            , overflow = "hidden"
            , width = 100
            , height = 148
            }
        , itemContainerBottomRadius =
            { height = 148
            }
        , itemImage =
            { justifyContent = "flex-end"
            , width = 100
            , height = 142
            }
        , itemImageAlt =
            { position = "absolute"
            , top = 0
            , left = 0
            , right = 0
            , bottom = 0
            , justifyContent = "center"
            , alignItems = "center"
            }
        , itemImageAltText =
            { fontSize = 12
            , color = "white"
            , fontWeight = "bold"
            }
        , itemLabel =
            { fontSize = 10
            , lineHeight = 10
            , fontWeight = "bold"
            , color = "white"
            }
        , itemLabelBackground =
            { alignItems = "center"
            , justifyContent = "flex-end"
            , height = 15
            , overflow = "hidden"
            }
        , progress =
            { backgroundColor = Theme.themeColor
            , height = 3
            }
        }


itemLabel : String -> Html msg
itemLabel label =
    imageBackground
        [ style homeStyles.itemLabelBackground
        , source <| require "./assets/gradient.png"
        , imageStyle { resizeMode = "repeat" }
        ]
        [ text [ style homeStyles.itemLabel ]
            [ str label ]
        ]


itemView : Client -> Bool -> Metadata -> Html Msg
itemView client isContinueWatching metadata =
    let
        { label, thumb, alt } =
            case metadata.typ of
                "episode" ->
                    { thumb = metadata.grandparentThumb
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index
                    , alt = metadata.grandparentTitle
                    }

                "season" ->
                    { thumb = metadata.thumb
                    , label = "S" ++ String.fromInt metadata.parentIndex
                    , alt = metadata.parentTitle
                    }

                _ ->
                    { thumb = metadata.thumb
                    , label = formatDuration metadata.duration
                    , alt = metadata.title
                    }

        progress =
            toFloat metadata.viewOffset / toFloat metadata.duration
    in
    touchableOpacity
        [ if isContinueWatching then
            style homeStyles.itemContainer

          else
            style <| StyleSheet.compose homeStyles.itemContainer homeStyles.itemContainerBottomRadius
        , onPress <| Decode.succeed <| GotoEntity isContinueWatching metadata
        ]
        [ view
            [ style homeStyles.itemImageAlt ]
            [ text [ style homeStyles.itemImageAltText ] [ str alt ] ]
        , imageBackground
            [ style homeStyles.itemImage
            , source
                { uri = Api.pathToAuthedUrl thumb client
                , width = 480
                , height = 719
                }
            , if isContinueWatching then
                imageStyle
                    { borderTopLeftRadius = 4
                    , borderTopRightRadius = 4
                    }

              else
                imageStyle
                    { borderRadius = 4
                    }
            ]
          <|
            if isContinueWatching then
                [ vidoePlayContainer (Decode.succeed NoOp)
                , itemLabel label
                ]

            else
                []
        , if isContinueWatching then
            view [ style homeStyles.progress, style { width = percentFloat progress } ] []

          else
            null
        ]


sectionView : Client -> Section -> Html Msg
sectionView client section =
    let
        isContinueWatching =
            section.hubIdentifier == "home.continue"
    in
    view [ style homeStyles.sectionContainer ]
        [ text [ style homeStyles.sectionTitle ] [ str section.title ]
        , scrollView
            [ contentContainerStyle homeStyles.sectionContent
            , showsHorizontalScrollIndicator False
            , horizontal True
            ]
            (List.map (itemView client isContinueWatching) section.data)
        ]


retryGetSections : String -> Html Msg
retryGetSections s =
    button [ title s, onPress <| Decode.succeed ReloadSections, color Theme.themeColor ] []


homeScreen : HomeModel -> a -> Html Msg
homeScreen model _ =
    case model.sections of
        Just (Ok ss) ->
            let
                sections =
                    List.filter (\s -> (not <| List.isEmpty s.data) && s.hubIdentifier /= "home.ondeck") ss
            in
            if List.isEmpty sections then
                view []
                    [ image [ source <| require "./assets/norecords.png", style { width = 60, height = 80 } ] []
                    , retryGetSections "Reload"
                    ]

            else
                scrollView
                    [ persistentScrollbar False
                    , contentContainerStyle homeStyles.container
                    , style { backgroundColor = Theme.backgroundColor }
                    ]
                <|
                    List.map (sectionView model.client) <|
                        sections

        Just (Err err) ->
            let
                _ =
                    Debug.log "err" err
            in
            view [ style homeStyles.loading ]
                [ ionicon "alert-circle-outline" [ size 60, color "darkred" ]
                , retryGetSections "Retry"
                ]

        _ ->
            view
                [ style homeStyles.loading ]
                [ activityIndicator [] [] ]
