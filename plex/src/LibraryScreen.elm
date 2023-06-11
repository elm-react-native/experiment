module LibraryScreen exposing (..)

import Api
import Client exposing (Client)
import Components exposing (bottomPadding, loading, progressBar, text, videoPlayContainer)
import Dict
import Dto exposing (Library, Metadata)
import Html exposing (Html)
import Html.Lazy exposing (lazy5)
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
import ReactNative.ContextMenuIOS as CM exposing (MenuItem, MenuItemAttribute, contextMenuButton, isMenuPrimaryAction, menuConfig, onPressMenuItem, pressEventMenuItemDecoder)
import ReactNative.Events exposing (onPress, onRefresh)
import ReactNative.Icon exposing (ionicon)
import ReactNative.PixelRatio as PixelRatio
import ReactNative.Platform as Platform
import ReactNative.Properties as Props
    exposing
        ( color
        , contentContainerStyle
        , horizontal
        , imageStyle
        , initialNumToRender
        , numColumns
        , persistentScrollbar
        , refreshCtrl
        , refreshing
        , showsHorizontalScrollIndicator
        , showsVerticalScrollIndicator
        , size
        , source
        , style
        , title
        , zoomScale
        )
import ReactNative.StyleSheet as StyleSheet
import Theme
import Utils exposing (formatDuration, percentFloat)


libraryScreen : HomeModel -> Library -> Html HomeMsg
libraryScreen model library =
    view [ style styles.container ]
        [ case Dict.get library.key model.librariesDetails of
            Just (Ok data) ->
                itemsView model.client data

            Just (Err _) ->
                text [] [ str "load failed" ]

            _ ->
                loading
        ]


itemsView client data =
    flatList
        { renderItem = \{ item } -> itemView client item
        , keyExtractor = \item _ -> item.guid
        , getItemLayout = Utils.fixedSizeLayout 110
        , data = data
        }
        [ showsHorizontalScrollIndicator False
        , showsVerticalScrollIndicator False
        , numColumns 4
        ]


itemView client metadata =
    let
        { label, thumb, alt, videoRatingKey, viewOffset, duration } =
            case metadata.typ of
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
        [ style styles.itemContainer
        , onPress <| Decode.succeed <| GotoEntity False metadata
        ]
        [ view
            [ style styles.itemImageAlt ]
            [ text [ style styles.itemImageAltText ] [ str alt ] ]
        , imageBackground
            [ style styles.itemImage
            , source
                { uri =
                    Api.transcodedImageUrl thumb
                        (PixelRatio.getPixelSizeForLayoutSize bannerWidth)
                        (PixelRatio.getPixelSizeForLayoutSize bannerHeight)
                        client
                }
            , imageStyle
                { borderRadius = itemBorderRadius
                }
            ]
            []
        ]


itemBorderRadius =
    if Platform.isPad then
        6

    else
        4


bannerWidth =
    if Platform.isPad then
        150

    else
        80


bannerHeight =
    if Platform.isPad then
        225

    else
        120


itemGap =
    if Platform.isPad then
        10

    else
        5


itemLabelSize =
    if Platform.isPad then
        15

    else
        10


itemLabelBackgroundHeight =
    if Platform.isPad then
        22

    else
        15


itemImageAltSize =
    if Platform.isPad then
        18

    else
        12


styles =
    StyleSheet.create
        { container =
            { backgroundColor = Theme.backgroundColor
            , height = "100%"
            , width = "100%"
            , paddingVertical = 10
            , paddingHorizontal = 5
            , alignItems = "center"
            }
        , itemContainer =
            { marginHorizontal = itemGap
            , marginVertical = itemGap
            , overflow = "hidden"
            , width = bannerWidth
            , height = bannerHeight
            , justifyContent = "flex-end"
            }
        , itemImage =
            { position = "absolute"
            , top = 0
            , left = 0
            , right = 0
            , bottom = 0
            , justifyContent = "flex-end"
            }
        , itemImageAlt =
            { position = "absolute"
            , top = 0
            , left = 0
            , right = 0
            , bottom = 0
            , justifyContent = "center"
            , alignItems = "center"
            , backgroundColor = "black"
            , borderRadius = itemBorderRadius
            }
        , itemImageAltText =
            { fontSize = itemImageAltSize
            , fontWeight = "bold"
            }
        , itemLabel =
            { fontSize = itemLabelSize
            , lineHeight = itemLabelSize
            , fontWeight = "bold"
            }
        , itemLabelBackground =
            { alignItems = "center"
            , justifyContent = "flex-end"
            , height = itemLabelBackgroundHeight
            , overflow = "hidden"
            }
        }
