module HomeScreen exposing (homeScreen)

import Api exposing (Client, Library, Metadata)
import Components exposing (bottomPadding, progressBar, text, videoPlayContainer)
import Dict
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
        , size
        , source
        , style
        , title
        , zoomScale
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
        , container = { backgroundColor = Theme.backgroundColor }
        , sectionContainer =
            { paddingVertical = 12 }
        , sectionTitleContainer =
            { marginLeft = 5
            , marginBottom = 6
            , flexDirection = "row"
            , alignItems = "center"
            , alignSelf = "flex-start"
            , gap = 3
            }
        , sectionTitle =
            { fontSize = 16
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
            { marginHorizontal = 5
            , overflow = "hidden"
            , width = 100
            , height = 150
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
            , borderRadius = 4
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
                        (PixelRatio.getPixelSizeForLayoutSize 100)
                        (PixelRatio.getPixelSizeForLayoutSize 150)
                        client
                }
            , imageStyle { borderRadius = 4 }
            ]
          <|
            if isContinueWatching then
                [ videoPlayContainer 48 (Decode.succeed <| PlayVideo metadata)
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


libraryMenu : Library -> Html Msg -> Html Msg
libraryMenu { key, scanning } child =
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map (\{ actionKey } -> ScanLibrary actionKey)
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , menuConfig
            { menuTitle = ""
            , menuItems =
                [ if scanning then
                    { actionKey = key
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
        [ child ]


sectionContainer : Maybe Library -> String -> Html Msg -> Html Msg
sectionContainer maybeLibrary title child =
    view [ style homeStyles.sectionContainer ]
        [ case maybeLibrary of
            Just library ->
                libraryMenu library <|
                    touchableOpacity
                        [ style homeStyles.sectionTitleContainer ]
                        [ text
                            [ style homeStyles.sectionTitle ]
                            [ str title ]
                        , ionicon "chevron-down-outline" [ size 15, color "white" ]
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


sectionView : Client -> Maybe Library -> String -> Bool -> RemoteData (List Metadata) -> Html Msg
sectionView client maybeLibrary title isContinueWatching resp =
    case resp of
        Just (Ok data) ->
            lazy5 sectionViewData client maybeLibrary title isContinueWatching data

        Just (Err _) ->
            sectionContainer Nothing title <| text [] [ str "Load failed" ]

        _ ->
            sectionContainer Nothing title null


homeScreen : HomeModel -> a -> Html Msg
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
