module EntityScreen exposing (entityScreen)

import Api exposing (Client, Metadata)
import Components exposing (bottomPadding, chip, progressBar, videoPlayContainer)
import Dict
import Html exposing (Html)
import Json.Decode as Decode
import Model exposing (..)
import ReactNative
    exposing
        ( activityIndicator
        , flatList
        , fragment
        , image
        , imageBackground
        , null
        , require
        , scrollView
        , str
        , text
        , touchableOpacity
        , view
        )
import ReactNative.ContextMenuIOS exposing (MenuItem, contextMenuButton, isMenuPrimaryAction, menuConfig, onPressMenuItem, pressEventMenuItemDecoder)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.Properties
    exposing
        ( color
        , contentContainerStyle
        , imageStyle
        , initialNumToRender
        , listFooterNode
        , listHeaderNode
        , resizeMode
        , size
        , source
        , style
        , title
        )
import Theme
import Utils exposing (formatDuration, percentFloat)


heroImage : String -> Client -> Html msg
heroImage thumb client =
    view
        [ style
            { shadowColor = "black"
            , shadowRadius = 10
            , shadowOpacity = 0.4
            , shadowOffset = { width = 0, height = 5 }
            , backgroundColor = "black"
            }
        ]
        [ image
            [ source
                { uri = Api.transcodedImageUrl thumb 480 719 client
                , width = 480
                , height = 719
                , cache = "force-cache"
                }
            , style { height = 210, width = "100%" }
            ]
            []
        ]


heroTitle : String -> Html msg
heroTitle title =
    text
        [ style
            { fontSize = 18
            , fontWeight = "bold"
            , color = "white"
            , marginTop = 10
            }
        ]
        [ str title ]


heroInfo : RemoteData TVShow -> Metadata -> Html msg
heroInfo tvShow metadata =
    let
        { originallyAvailableAt, contentRating, audienceRating, audienceRatingImage, duration } =
            case metadata.typ of
                "show" ->
                    { originallyAvailableAt = metadata.originallyAvailableAt
                    , contentRating = metadata.contentRating
                    , audienceRating = metadata.audienceRating
                    , audienceRatingImage = metadata.audienceRatingImage
                    , duration = 0
                    }

                "season" ->
                    case tvShow of
                        Just (Ok { info }) ->
                            { originallyAvailableAt = info.originallyAvailableAt
                            , contentRating = info.contentRating
                            , audienceRating = info.audienceRating
                            , audienceRatingImage = info.audienceRatingImage
                            , duration = 0
                            }

                        _ ->
                            { originallyAvailableAt = ""
                            , contentRating = ""
                            , audienceRating = 0
                            , audienceRatingImage = ""
                            , duration = 0
                            }

                "episode" ->
                    case tvShow of
                        Just (Ok { info }) ->
                            { originallyAvailableAt = metadata.originallyAvailableAt
                            , contentRating = info.contentRating
                            , audienceRating = info.audienceRating
                            , audienceRatingImage = info.audienceRatingImage
                            , duration = metadata.duration
                            }

                        _ ->
                            { originallyAvailableAt = metadata.originallyAvailableAt
                            , contentRating = metadata.contentRating
                            , audienceRating = 0
                            , audienceRatingImage = ""
                            , duration = metadata.duration
                            }

                _ ->
                    { originallyAvailableAt = metadata.originallyAvailableAt
                    , contentRating = metadata.contentRating
                    , audienceRating = metadata.audienceRating
                    , audienceRatingImage = metadata.audienceRatingImage
                    , duration = metadata.duration
                    }
    in
    view [ style { flexDirection = "row", marginTop = 10, gap = 5 } ]
        [ if String.isEmpty originallyAvailableAt then
            null

          else
            text
                [ style
                    { color = "white"
                    , fontSize = 12
                    }
                ]
                [ str <| String.slice 0 4 originallyAvailableAt ]
        , if String.isEmpty contentRating then
            null

          else
            chip contentRating
        , if audienceRating == 0 then
            null

          else
            ratingView audienceRating audienceRatingImage
        , if duration == 0 then
            null

          else
            text [ style { color = "white", fontSize = 12 } ] [ str <| formatDuration metadata.duration ]
        ]


ratingView score icon =
    let
        ( src, size ) =
            case icon of
                "rottentomatoes://image.rating.rotten" ->
                    ( require "./assets/rottentomatoes.image.rating.rotten.png", { width = 15, height = 15 } )

                "rottentomatoes://image.rating.upright" ->
                    ( require "./assets/rottentomatoes.image.rating.upright.png", { width = 15, height = 15 } )

                _ ->
                    ( require "./assets/themoviedb.image.rating.png", { width = 30, height = 15 } )
    in
    view [ style { flexDirection = "row" } ]
        [ image
            [ source src
            , style size
            ]
            []
        , text [ style { color = "white", fontSize = 12 } ] [ str <| percentFloat <| score / 10 ]
        ]


heroPlayButton : String -> Maybe Int -> Int -> Bool -> Html Msg
heroPlayButton ratingKey viewOffset duration isContinueWatching =
    touchableOpacity [ onPress <| Decode.succeed <| PlayVideo ratingKey viewOffset duration ]
        [ view
            [ style
                { justifyContent = "center"
                , alignItems = "center"
                , backgroundColor = "white"
                , borderRadius = 3
                , height = 35
                , marginTop = 15
                , flexDirection = "row"
                }
            ]
            [ text [ style { color = "black", fontSize = 30, top = 2, right = 2 } ] [ str "⏵" ]
            , text [ style { color = "black", fontWeight = "bold" } ]
                [ str <|
                    if isContinueWatching then
                        " Resume"

                    else
                        "Play"
                ]
            ]
        ]


heroLabel : String -> Html msg
heroLabel label =
    text
        [ style
            { color = "white"
            , fontWeight = "bold"
            , fontSize = 15
            , marginTop = 10
            }
        ]
        [ str label ]


heroProgressBar : Int -> Int -> String -> Html msg
heroProgressBar viewOffset duration label =
    let
        progress =
            toFloat viewOffset / toFloat duration

        remainingDuration =
            formatDuration (duration - viewOffset) ++ " remaining"
    in
    view
        [ style
            { flexDirection = "row"
            , alignItems = "center"
            , justifyContent = "space-between"
            , marginTop =
                if String.isEmpty label then
                    20

                else
                    10
            }
        ]
        [ progressBar [ style { flexGrow = 1, marginRight = 10 } ] progress
        , text [ style { color = "gray", fontSize = 9 } ] [ str remainingDuration ]
        ]


heroSummary : RemoteData TVShow -> Metadata -> Html msg
heroSummary tvShow metadata =
    let
        summary =
            if metadata.typ == "show" then
                metadata.summary

            else if metadata.typ == "episode" || metadata.typ == "season" then
                case tvShow of
                    Just (Ok { info }) ->
                        info.summary

                    _ ->
                        ""

            else
                metadata.summary
    in
    if String.isEmpty summary then
        null

    else
        text
            [ style
                { fontSize = 12
                , color = "white"
                , marginTop = 5
                }
            ]
            [ str summary ]


episodeView : Client -> Metadata -> Html Msg
episodeView client ep =
    view []
        [ view [ style { flexDirection = "row", marginTop = 15, alignItems = "center" } ]
            [ imageBackground
                [ source
                    { uri = Api.transcodedImageUrl ep.thumb 720 404 client
                    , width = 720
                    , height = 404
                    , cache = "force-cache"
                    }
                , style { width = 112, height = 63, justifyContent = "flex-end" }
                , imageStyle { borderRadius = 4, resizeMode = "contain" }
                ]
                [ videoPlayContainer 15 (Decode.succeed <| PlayVideo ep.ratingKey ep.viewOffset ep.duration)
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
            , view [ style { marginLeft = 5 } ]
                [ text
                    [ style
                        { color = "white"
                        , marginRight = 10
                        }
                    ]
                    [ str <| String.fromInt ep.index ++ ". " ++ ep.title ]
                , text [ style { color = "gray", fontSize = 12, marginTop = 3 } ] [ str <| formatDuration ep.duration ]
                ]
            ]
        , text [ style { color = "gray", fontSize = 12, marginTop = 4 } ] [ str ep.summary ]
        ]


seasonView : Int -> TVShow -> Html Msg
seasonView selectedSeasonIndex show =
    let
        selectedSeasonLabel =
            "Season " ++ String.fromInt selectedSeasonIndex
    in
    contextMenuButton
        [ pressEventMenuItemDecoder
            |> Decode.map (\{ actionKey } -> ChangeSeason show.info.ratingKey actionKey)
            |> onPressMenuItem
        , isMenuPrimaryAction True
        , style { marginTop = 20 }
        , menuConfig
            { menuTitle = show.info.title
            , menuItems =
                List.map
                    (\sz ->
                        { actionKey = sz.info.ratingKey
                        , actionTitle = "Season " ++ String.fromInt sz.info.index
                        }
                    )
                    show.seasons
            }
        ]
        [ touchableOpacity
            [ style
                { flexDirection = "row"
                , alignItems = "center"
                , alignSelf = "flex-start"
                }
            ]
            [ text
                [ style
                    { fontWeight = "bold"
                    , color = "white"
                    , marginRight = 5
                    }
                ]
                [ str selectedSeasonLabel ]
            , ionicon "chevron-down-outline" [ size 12, color "white" ]
            ]
        ]


loadingEposidesIndicator marginTop =
    view
        [ style
            { height = 50
            , justifyContent = "center"
            , alignItems = "center"
            , marginTop = marginTop
            }
        ]
        [ activityIndicator [] [] ]


entityEposidesHeader tvShow =
    case tvShow of
        Just (Ok show) ->
            case findSeason show.selectedSeason show of
                Just selectedSeason ->
                    fragment
                        []
                        [ seasonView selectedSeason.info.index show
                        , case selectedSeason.episodes of
                            Just (Ok _) ->
                                null

                            Just (Err _) ->
                                view []
                                    [ text [] [ str "Load episodes error" ]
                                    ]

                            _ ->
                                loadingEposidesIndicator 20
                        ]

                _ ->
                    null

        Just (Err _) ->
            view [ style { marginTop = 20 } ]
                [ text [] [ str "Load show failed." ]
                ]

        _ ->
            loadingEposidesIndicator 0


entityInfo isContinueWatching tvShow metadata =
    let
        { title, label, showProgress, showPlayButton, displayEpisodes } =
            case metadata.typ of
                "episode" ->
                    { title = metadata.grandparentTitle
                    , showId = metadata.grandparentRatingKey
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index ++ " " ++ metadata.title
                    , showProgress = isContinueWatching
                    , showPlayButton = True
                    , displayEpisodes = True
                    }

                "season" ->
                    { title = metadata.parentTitle
                    , showId = metadata.parentRatingKey
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , displayEpisodes = True
                    }

                "show" ->
                    { title = metadata.title
                    , showId = metadata.ratingKey
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , displayEpisodes = True
                    }

                "movie" ->
                    { title = metadata.title
                    , showId = ""
                    , label = ""
                    , showProgress = isContinueWatching
                    , showPlayButton = True
                    , displayEpisodes = False
                    }

                _ ->
                    { title = metadata.title
                    , showId = ""
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , displayEpisodes = False
                    }
    in
    fragment []
        [ heroTitle title
        , heroInfo tvShow metadata
        , if showPlayButton then
            heroPlayButton metadata.ratingKey metadata.viewOffset metadata.duration isContinueWatching

          else
            null
        , if String.isEmpty label then
            null

          else
            heroLabel label
        , if showProgress then
            heroProgressBar (Maybe.withDefault metadata.duration metadata.viewOffset) metadata.duration label

          else
            null
        , heroSummary tvShow metadata
        , if displayEpisodes then
            entityEposidesHeader tvShow

          else
            null
        ]


entityScreen : HomeModel -> { isContinueWatching : Bool, metadata : Metadata } -> Html Msg
entityScreen model { isContinueWatching, metadata } =
    let
        client =
            model.client

        { showId, displayEpisodes } =
            case metadata.typ of
                "episode" ->
                    { showId = metadata.grandparentRatingKey
                    , displayEpisodes = True
                    }

                "season" ->
                    { showId = metadata.parentRatingKey
                    , displayEpisodes = True
                    }

                "show" ->
                    { showId = metadata.ratingKey
                    , displayEpisodes = True
                    }

                "movie" ->
                    { showId = ""
                    , displayEpisodes = False
                    }

                _ ->
                    { showId = ""
                    , displayEpisodes = False
                    }

        tvShow : RemoteData TVShow
        tvShow =
            Dict.get showId model.tvShows

        episodes =
            if displayEpisodes then
                case tvShow of
                    Just (Ok show) ->
                        case findSeason show.selectedSeason show of
                            Just selectedSeason ->
                                case selectedSeason.episodes of
                                    Just (Ok eps) ->
                                        eps

                                    _ ->
                                        []

                            _ ->
                                []

                    _ ->
                        []

            else
                []
    in
    view
        [ style
            { backgroundColor = Theme.backgroundColor
            , width = "100%"
            , height = "100%"
            }
        ]
        [ heroImage metadata.thumb client
        , flatList
            { data = episodes
            , keyExtractor = \ep _ -> ep.guid
            , renderItem = \{ item } -> episodeView client item
            , getItemLayout = Nothing
            }
            [ listHeaderNode <| entityInfo isContinueWatching tvShow metadata
            , listFooterNode bottomPadding
            , contentContainerStyle { paddingHorizontal = 10 }
            , initialNumToRender 4
            ]
        ]
