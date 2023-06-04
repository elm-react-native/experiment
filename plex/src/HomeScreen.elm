module HomeScreen exposing (homeScreen)

import Api
import Client exposing (Client)
import Components exposing (bottomPadding, progressBar, text, videoPlayContainer)
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


bannerWidth =
    if Platform.isPad then
        150

    else
        100


bannerHeight =
    if Platform.isPad then
        225

    else
        150


sectionTitleSize =
    if Platform.isPad then
        24

    else
        16


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


itemBorderRadius =
    if Platform.isPad then
        6

    else
        4


itemGap =
    if Platform.isPad then
        10

    else
        5


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
            { paddingVertical = 12 }
        , sectionTitleContainer =
            { marginLeft = itemGap
            , marginBottom = 6
            }
        , sectionTitle =
            { fontSize = sectionTitleSize
            , fontWeight = "bold"
            }
        , sectionContent =
            { flexDirection = "row"
            , alignItems = "center"
            , justifyContent = "center"
            }
        , sectionContentLoading =
            { width = "100%" }
        , itemContainer =
            { marginHorizontal = itemGap
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


itemView : Client -> Bool -> Metadata -> Html HomeMsg
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
        [ style homeStyles.itemContainer
        , onPress <| Decode.succeed <| GotoEntity isContinueWatching metadata
        ]
        [ view
            [ style homeStyles.itemImageAlt ]
            [ text [ style homeStyles.itemImageAltText ] [ str alt ] ]
        , imageBackground
            [ style homeStyles.itemImage
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
          <|
            if isContinueWatching then
                [ videoPlayContainer
                    (if Platform.isPad then
                        72

                     else
                        48
                    )
                    (Decode.succeed <| PlayVideo metadata)
                ]

            else
                []
        , if isContinueWatching then
            view []
                [ itemLabel label
                , progressBar [] <| toFloat (Maybe.withDefault metadata.duration metadata.viewOffset) / toFloat metadata.duration
                ]

          else
            null
        ]


libraryMenu : Library -> List (Html HomeMsg) -> Html HomeMsg
libraryMenu { key, scanning, title } children =
    touchableOpacity
        [ style homeStyles.sectionTitleContainer ]
        [ contextMenuButton
            [ pressEventMenuItemDecoder
                |> Decode.map
                    (\{ actionKey } -> ScanLibrary actionKey)
                |> onPressMenuItem
            , isMenuPrimaryAction True
            , style { alignSelf = "flex-start" }
            , menuConfig
                { menuTitle = title
                , menuItems =
                    [ if scanning then
                        { actionKey = ""
                        , actionTitle = "Scanning..."
                        , attributes = Just [ CM.KeepsMenuPresented, CM.Disabled ]
                        }

                      else
                        { actionKey = key
                        , actionTitle = "Scan Library"
                        , attributes = Just [ CM.KeepsMenuPresented ]
                        }
                    ]
                }
            ]
            children
        ]


sectionContainer : Maybe Library -> String -> Html HomeMsg -> Html HomeMsg
sectionContainer maybeLibrary title child =
    view [ style homeStyles.sectionContainer ]
        [ case maybeLibrary of
            Just library ->
                libraryMenu library <|
                    [ text
                        [ style homeStyles.sectionTitle ]
                        [ str title
                        , ionicon "chevron-down-outline" [ size 15, color "white" ]
                        ]
                    ]

            _ ->
                text [ style homeStyles.sectionTitleContainer, style homeStyles.sectionTitle ] [ str title ]
        , child
        ]


sectionViewData client maybeLibrary title isContinueWatching data =
    sectionContainer maybeLibrary title <|
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


sectionView : Client -> Maybe Library -> String -> Bool -> RemoteData (List Metadata) -> Html HomeMsg
sectionView client maybeLibrary title isContinueWatching resp =
    case resp of
        Just (Ok data) ->
            lazy5 sectionViewData client maybeLibrary title isContinueWatching data

        Just (Err _) ->
            sectionContainer Nothing title <| text [] [ str "Load failed" ]

        _ ->
            sectionContainer Nothing title null


homeScreen : HomeModel -> a -> Html HomeMsg
homeScreen model _ =
    let
        client =
            model.client

        recentlyAddedSectionViews =
            List.map
                (\lib ->
                    sectionView client Nothing ("Recently Added in " ++ lib.title) False <|
                        Dict.get lib.key model.librariesRecentlyAdded
                )
                model.libraries

        libraryDetailsSectionViews =
            List.map
                (\lib ->
                    sectionView client (Just lib) lib.title False <|
                        Dict.get lib.key model.librariesDetails
                )
                model.libraries
    in
    scrollView
        [ persistentScrollbar False
        , contentContainerStyle homeStyles.container
        , showsHorizontalScrollIndicator False
        , showsVerticalScrollIndicator False
        , style { backgroundColor = Theme.backgroundColor }
        , refreshCtrl <|
            refreshControl
                [ onRefresh (Decode.succeed RefreshHomeScreen)
                , refreshing model.refreshing
                ]
        ]
    <|
        [ lazy5 sectionView model.client Nothing "Continue Watching" True model.continueWatching
        ]
            ++ recentlyAddedSectionViews
            ++ libraryDetailsSectionViews
            ++ [ bottomPadding ]
