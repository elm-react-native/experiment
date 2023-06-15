module LibraryScreen exposing (..)

import Api
import Client exposing (Client)
import Components exposing (bottomPadding, loading, progressBar, text, videoPlayContainer)
import Dict
import Dto exposing (Library, Metadata)
import Html exposing (Html)
import Html.Lazy exposing (lazy5)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
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
        , key
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
libraryScreen { librariesDetails, client } library =
    view
        [ style styles.container ]
        [ case Dict.get library.key librariesDetails of
            Just (Ok data) ->
                itemsView client data

            Just (Err _) ->
                text [] [ str "load failed" ]

            _ ->
                loading
        ]


isLandscape { width, height } =
    width > height


getNumColumns metrics =
    if isLandscape metrics then
        num // 2 * 3

    else
        num


getItemWidth metrics =
    let
        n =
            getNumColumns metrics
    in
    ( n, metrics.width / toFloat n - (itemGap * 2) )


itemsView client data =
    let
        ( n, w ) =
            getItemWidth client.screenMetrics
    in
    flatList
        { renderItem = \{ item } -> itemView client item
        , keyExtractor = \item _ -> item.guid
        , getItemLayout = Utils.fixedSizeLayout w
        , data = data
        }
        [ showsHorizontalScrollIndicator False
        , showsVerticalScrollIndicator False
        , numColumns n
        , key (String.fromInt n)
        ]


itemView client metadata =
    let
        ( n, w ) =
            getItemWidth client.screenMetrics

        h =
            (w * 3) / 2

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
        [ style <| styles.itemContainer w h
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
                        (PixelRatio.getPixelSizeForLayoutSize w)
                        (PixelRatio.getPixelSizeForLayoutSize h)
                        client
                }
            , imageStyle
                { borderRadius = itemBorderRadius
                }
            ]
            []
        ]


num =
    if Platform.isPad then
        6

    else
        4


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
            , alignItems = "center"
            }
        , itemContainer =
            \w h ->
                { marginHorizontal = itemGap
                , marginVertical = itemGap
                , overflow = "hidden"
                , width = w
                , height = h
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
