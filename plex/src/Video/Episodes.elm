module Video.Episodes exposing (episodesView)

import Api exposing (Client, Metadata)
import Browser
import Components exposing (progressBar, text, videoPlayContainer)
import Dict
import EntityScreen exposing (seasonMenu)
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Model exposing (HomeModel, Msg(..), VideoPlayerControlAction(..))
import ReactNative exposing (activityIndicator, flatList, fragment, imageBackground, null, str, touchableOpacity, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.PixelRatio as PixelRatio
import ReactNative.Properties exposing (color, contentContainerStyle, horizontal, imageStyle, initialScrollIndex, numberOfLines, showsHorizontalScrollIndicator, size, source, stringSize, style)
import ReactNative.StyleSheet as StyleSheet
import Theme
import Utils


episodeView : Client -> Metadata -> Html Msg
episodeView client ep =
    view [ style { width = 210, paddingHorizontal = 5, gap = 5 } ]
        [ view
            [ style
                { alignItems = "center"
                , overflow = "hidden"
                }
            ]
            [ imageBackground
                [ source
                    { uri =
                        Api.transcodedImageUrl ep.thumb
                            (PixelRatio.getPixelSizeForLayoutSize 210)
                            (PixelRatio.getPixelSizeForLayoutSize 117.83)
                            client
                    , width = 210
                    , height = 117.83
                    , cache = "force-cache"
                    }
                , style { width = 210, height = 117.83, justifyContent = "flex-end" }
                , imageStyle { borderRadius = 6, resizeMode = "contain" }
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


loading =
    activityIndicator [ stringSize "large" ] []


styles =
    StyleSheet.create
        { container =
            { width = "100%"
            , height = "100%"
            , backgroundColor = "black"
            , gap = 15
            , alignItems = "center"
            , justifyContent = "center"
            }
        }


episodesView : HomeModel -> Html Msg
episodesView { client, tvShows, videoPlayer } =
    let
        metadata =
            videoPlayer.metadata
    in
    view [ style styles.container ]
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
                                            , paddingHorizontal = 40
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
                                        , ionicon "ios-close"
                                            [ color "white"
                                            , size 25
                                            , onPress <| Decode.succeed <| VideoPlayerControl <| SetEpisodesOpen False
                                            ]
                                        ]
                                    , flatList
                                        { data = episodes
                                        , keyExtractor = \ep _ -> ep.guid
                                        , renderItem = \{ item } -> episodeView client item
                                        , getItemLayout = Utils.fixedSizeLayout 210
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
