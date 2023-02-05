module HomeScreen exposing (homeScreen)

import Api exposing (Client, Metadata)
import Components exposing (bottomPadding, progressBar, text, videoPlayContainer)
import Dict
import Html exposing (Html)
import Html.Lazy exposing (lazy4)
import Json.Decode as Decode
import Model exposing (..)
import ReactNative
    exposing
        ( activityIndicator
        , button
        , flatList
        , fragment
        , image
        , imageBackground
        , null
        , refreshControl
        , require
        , scrollView
        , str
        , touchableOpacity
        , touchableScale
        , view
        )
import ReactNative.Events exposing (onPress, onRefresh)
import ReactNative.Icon exposing (ionicon)
import ReactNative.PixelRatio as PixelRatio
import ReactNative.Properties
    exposing
        ( color
        , contentContainerStyle
        , horizontal
        , imageStyle
        , initialNumToRender
        , persistentScrollbar
        , refreshCtrl
        , refreshing
        , showsHorizontalScrollIndicator
        , size
        , source
        , style
        , title
        , zoomScale
        )
import ReactNative.StyleSheet as StyleSheet
import ReactNative.Video exposing (video)
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
        , container = { backgroundColor = Theme.backgroundColor }
        , sectionContainer =
            { height = 180, paddingVertical = 5 }
        , sectionTitle =
            { fontSize = 15
            , fontWeight = "bold"
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
            , fontWeight = "bold"
            }
        , itemLabel =
            { fontSize = 10
            , lineHeight = 10
            , fontWeight = "bold"
            }
        , itemLabelBackground =
            { alignItems = "center"
            , justifyContent = "flex-end"
            , height = 15
            , overflow = "hidden"
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
        { label, thumb, alt, videoRatingKey, viewOffset, duration } =
            case metadata.typ of
                "episode" ->
                    { thumb = metadata.grandparentThumb
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index
                    , alt = metadata.grandparentTitle
                    , videoRatingKey = metadata.ratingKey
                    , viewOffset = metadata.viewOffset
                    , duration = metadata.duration
                    }

                "season" ->
                    { thumb = metadata.thumb
                    , label = "S" ++ String.fromInt metadata.parentIndex
                    , alt = metadata.parentTitle
                    , videoRatingKey = ""
                    , viewOffset = Nothing
                    , duration = 0
                    }

                "movie" ->
                    { thumb = metadata.thumb
                    , label = formatDuration metadata.duration
                    , alt = metadata.title
                    , videoRatingKey = metadata.ratingKey
                    , viewOffset = metadata.viewOffset
                    , duration = metadata.duration
                    }

                _ ->
                    { thumb = metadata.thumb
                    , label = formatDuration metadata.duration
                    , alt = metadata.title
                    , videoRatingKey = ""
                    , viewOffset = Nothing
                    , duration = 0
                    }
    in
    touchableScale
        [ if isContinueWatching then
            style homeStyles.itemContainer

          else
            style <| StyleSheet.compose homeStyles.itemContainer homeStyles.itemContainerBottomRadius
        , onPress <| Decode.succeed <| GotoEntity isContinueWatching metadata
        , zoomScale 0.94
        ]
        [ view
            [ style homeStyles.itemImageAlt ]
            [ text [ style homeStyles.itemImageAltText ] [ str alt ] ]
        , imageBackground
            [ style homeStyles.itemImage
            , source
                { uri =
                    Api.transcodedImageUrl thumb
                        (PixelRatio.getPixelSizeForLayoutSize 100)
                        (PixelRatio.getPixelSizeForLayoutSize 142)
                        client
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
                [ videoPlayContainer 48 (Decode.succeed <| PlayVideo metadata)
                , itemLabel label
                ]

            else
                []
        , if isContinueWatching then
            progressBar [] <| toFloat (Maybe.withDefault metadata.duration metadata.viewOffset) / toFloat metadata.duration

          else
            null
        ]


sectionContainer : String -> Html Msg -> Html Msg
sectionContainer title child =
    view [ style homeStyles.sectionContainer ]
        [ text [ style homeStyles.sectionTitle ] [ str title ]
        , child
        ]


sectionViewData client title isContinueWatching data =
    sectionContainer title <|
        flatList
            { renderItem = \{ item } -> itemView client isContinueWatching item
            , keyExtractor = \item _ -> item.guid
            , getItemLayout = Utils.fixedSizeLayout 110
            , data = data
            }
            [ contentContainerStyle homeStyles.sectionContent
            , showsHorizontalScrollIndicator False
            , horizontal True
            , initialNumToRender 4
            ]


sectionView : Client -> String -> Bool -> RemoteData (List Metadata) -> Html Msg
sectionView client title isContinueWatching resp =
    case resp of
        Just (Ok data) ->
            lazy4 sectionViewData client title isContinueWatching data

        Just (Err _) ->
            sectionContainer title <| text [] [ str "Load failed" ]

        _ ->
            sectionContainer title null


homeScreen : HomeModel -> a -> Html Msg
homeScreen model _ =
    let
        client =
            model.client

        recentlyAddedSectionViews =
            List.map
                (\lib ->
                    sectionView client ("Recently Added in " ++ lib.title) False <|
                        Dict.get lib.key model.librariesRecentlyAdded
                )
                model.libraries

        libraryDetailsSectionViews =
            List.map
                (\lib ->
                    sectionView client lib.title False <|
                        Dict.get lib.key model.librariesDetails
                )
                model.libraries
    in
    scrollView
        [ persistentScrollbar False
        , contentContainerStyle homeStyles.container
        , style { backgroundColor = Theme.backgroundColor }
        , refreshCtrl <|
            refreshControl
                [ onRefresh (Decode.succeed RefreshHomeScreen)
                , refreshing model.refreshing
                ]
        ]
    <|
        [ lazy4 sectionView model.client "Continue Watching" True model.continueWatching
        ]
            ++ recentlyAddedSectionViews
            ++ libraryDetailsSectionViews
            ++ [ bottomPadding ]
