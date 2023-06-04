module Video.Episodes exposing (episodesView)

import Api
import Browser
import Client exposing (Client)
import Components exposing (loading, modalFadeView, progressBar, text, videoPlayContainer)
import Dict
import Dto exposing (Metadata)
import EntityScreen exposing (seasonMenu)
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Model exposing (HomeModel, HomeMsg(..), VideoPlayerControlAction(..))
import ReactNative exposing (activityIndicator, flatList, fragment, imageBackground, null, str, touchableOpacity, touchableScale, view)
import ReactNative.BlurView exposing (blurAmount, blurType)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.PixelRatio as PixelRatio
import ReactNative.Properties exposing (color, contentContainerStyle, horizontal, imageStyle, initialScrollIndex, numberOfLines, showsHorizontalScrollIndicator, size, source, stringSize, style, visible)
import ReactNative.StyleSheet as StyleSheet
import Theme
import Utils


styles =
    StyleSheet.create
        { fullScreen =
            { position = "absolute"
            , left = 0
            , top = 0
            , right = 0
            , bottom = 0
            }
        }


episodeView : Client -> Metadata -> Html HomeMsg
episodeView client ep =
    view [ style { width = 200, paddingHorizontal = 10, gap = 5 } ]
        [ view
            [ style
                { alignItems = "center"
                , width = 180
                , height = 101
                }
            ]
            [ imageBackground
                [ source
                    { uri =
                        Api.transcodedImageUrl ep.thumb
                            (PixelRatio.getPixelSizeForLayoutSize 180)
                            (PixelRatio.getPixelSizeForLayoutSize 101)
                            client
                    , width = 180
                    , height = 101
                    }
                , style
                    { justifyContent = "flex-end"
                    , width = 180
                    , height = 101
                    }
                , imageStyle { borderRadius = 6 }
                ]
                [ videoPlayContainer 40 (Decode.succeed <| PlayVideo ep)
                , case ep.lastViewedAt of
                    Just _ ->
                        progressBar []
                            (case ep.viewOffset of
                                Just viewOffset ->
                                    toFloat viewOffset / toFloat ep.duration

                                _ ->
                                    1
                            )

                    _ ->
                        null
                ]
            ]
        , view
            [ style
                { borderBottomWidth = StyleSheet.hairlineWidth
                , borderColor = "gray"
                , justifyContent = "center"
                , height = 40
                }
            ]
            [ text
                [ numberOfLines 2
                ]
                [ str <| String.fromInt ep.index ++ ". " ++ ep.title ]
            ]
        , text [ style { color = "gray", fontSize = 11 } ] [ str <| Utils.formatDuration ep.duration ]
        , text [ style { color = "gray", fontSize = 11 }, numberOfLines 5 ] [ str ep.summary ]
        ]


episodesView : HomeModel -> Html HomeMsg
episodesView { client, tvShows, videoPlayer } =
    let
        metadata =
            videoPlayer.metadata
    in
    modalFadeView
        [ style
            { gap = 15
            , alignItems = "center"
            , justifyContent = "center"
            , flex = 1
            }
        , contentContainerStyle styles.fullScreen
        , blurType "dark"
        , blurAmount 60
        , visible videoPlayer.episodesOpen
        ]
        [ case Dict.get metadata.grandparentRatingKey tvShows of
            Just (Ok tvShow) ->
                case
                    Utils.findItem
                        (\season -> season.info.ratingKey == videoPlayer.selectedSeasonKey)
                        tvShow.seasons
                of
                    Just season ->
                        let
                            selectedSeasonLabel =
                                "Season " ++ String.fromInt season.info.index
                        in
                        case season.episodes of
                            Just (Ok episodes) ->
                                let
                                    episodeIndex =
                                        Utils.indexOf (\ep -> ep.ratingKey == metadata.ratingKey) episodes
                                            |> Maybe.withDefault 0
                                in
                                fragment []
                                    [ view
                                        [ style
                                            { flexDirection = "row"
                                            , justifyContent = "space-between"
                                            , width = "100%"
                                            , height = 60
                                            , paddingHorizontal = 58
                                            , alignItems = "flex-end"
                                            }
                                        ]
                                        [ seasonMenu tvShow
                                            [ touchableOpacity
                                                [ style
                                                    { flexDirection = "row"
                                                    , alignItems = "center"
                                                    , backgroundColor = Theme.backgroundColor
                                                    , paddingVertical = 5
                                                    , paddingHorizontal = 10
                                                    , borderRadius = 2
                                                    , gap = 3
                                                    }
                                                ]
                                                [ text
                                                    [ style
                                                        { fontWeight = "bold"
                                                        , fontSize = 15
                                                        }
                                                    ]
                                                    [ str selectedSeasonLabel ]
                                                , ionicon "caret-down" [ size 13, color "white" ]
                                                ]
                                            ]
                                        , touchableScale [ onPress <| Decode.succeed <| VideoPlayerControl <| SetEpisodesOpen False ]
                                            [ ionicon "ios-close"
                                                [ color "white"
                                                , size 25
                                                ]
                                            ]
                                        ]
                                    , flatList
                                        { data = episodes
                                        , keyExtractor = \ep _ -> ep.guid
                                        , renderItem = \{ item } -> episodeView client item
                                        , getItemLayout = Utils.fixedSizeLayout 200
                                        }
                                        [ contentContainerStyle { flexGrow = 1, paddingHorizontal = 50 }
                                        , horizontal True
                                        , showsHorizontalScrollIndicator False
                                        , initialScrollIndex episodeIndex
                                        ]
                                    ]

                            Just (Err err) ->
                                Debug.todo "Alert error"

                            _ ->
                                loading

                    _ ->
                        loading

            Just (Err err) ->
                Debug.todo "Alert error"

            _ ->
                loading
        ]
