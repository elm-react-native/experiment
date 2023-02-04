module EntityScreen exposing (entityScreen, episodeTitle)

import Api exposing (Client, Metadata)
import Components exposing (bottomPadding, chip, progressBar, text, videoPlayContainer)
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
        , touchableOpacity
        , view
        )
import ReactNative.ContextMenuIOS exposing (MenuItem, contextMenuButton, isMenuPrimaryAction, menuConfig, onPressMenuItem, pressEventMenuItemDecoder)
import ReactNative.Dimensions exposing (DisplayMetrics)
import ReactNative.Events exposing (onPress)
import ReactNative.Icon exposing (ionicon)
import ReactNative.PixelRatio as PixelRatio
import ReactNative.Properties
    exposing
        ( color
        , contentContainerStyle
        , imageStyle
        , initialNumToRender
        , listFooterNode
        , listHeaderNode
        , numberOfLines
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


entityTitle : String -> Html msg
entityTitle title =
    text
        [ style
            { fontSize = 18
            , fontWeight = "bold"
            , marginTop = 10
            }
        ]
        [ str title ]


entityGeneral : RemoteData TVShow -> Metadata -> Html msg
entityGeneral tvShow metadata =
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
                    { fontSize = 12
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
            text [ style { fontSize = 12 } ] [ str <| formatDuration metadata.duration ]
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
        , text [ style { fontSize = 12 } ] [ str <| percentFloat <| score / 10 ]
        ]


entityPlayButton : Metadata -> Bool -> Html Msg
entityPlayButton ({ ratingKey, viewOffset, duration, typ } as metadata) isContinueWatching =
    let
        title =
            case typ of
                "episode" ->
                    episodeTitle metadata

                _ ->
                    metadata.title
    in
    touchableOpacity [ onPress <| Decode.succeed <| PlayVideo metadata ]
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
            [ ionicon "play" [ color "black", size 18, style { paddingRight = 5 } ]
            , text [ style { color = "black", fontWeight = "bold" } ]
                [ str <|
                    if isContinueWatching then
                        "Resume"

                    else
                        "Play"
                ]
            ]
        ]


entityLabel : String -> Html msg
entityLabel label =
    text
        [ style
            { fontWeight = "bold"
            , fontSize = 15
            , marginTop = 10
            }
        ]
        [ str label ]


entityProgressBar : Int -> Int -> String -> Html msg
entityProgressBar viewOffset duration label =
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


entitySummary : RemoteData TVShow -> Metadata -> Html msg
entitySummary tvShow metadata =
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
                , paddingVertical = 5
                }
            , numberOfLines 3
            ]
            [ str summary ]


episodeView : Client -> Metadata -> DisplayMetrics -> Html Msg
episodeView client ep metrics =
    fragment []
        [ view
            [ style
                { flexDirection = "row"
                , marginTop = 15
                , alignItems = "center"
                , gap = 5
                , overflow = "hidden"
                }
            ]
            [ imageBackground
                [ source
                    { uri =
                        Api.transcodedImageUrl ep.thumb
                            (PixelRatio.getPixelSizeForLayoutSize 112)
                            (PixelRatio.getPixelSizeForLayoutSize 63)
                            client
                    , width = 720
                    , height = 404
                    , cache = "force-cache"
                    }
                , style { width = 112, height = 63, justifyContent = "flex-end" }
                , imageStyle { borderRadius = 6, resizeMode = "contain" }
                ]
                [ videoPlayContainer 30 (Decode.succeed <| PlayVideo ep)
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
            , view
                [ style { width = metrics.width - 20 - 5 - 112 }
                ]
                [ text
                    [ numberOfLines 2 ]
                    [ str <| String.fromInt ep.index ++ ". " ++ ep.title ]
                , text [ style { color = "gray", fontSize = 12, marginTop = 3 } ] [ str <| formatDuration ep.duration ]
                ]
            ]
        , text [ style { color = "gray", fontSize = 12, marginTop = 4 }, numberOfLines 3 ] [ str ep.summary ]
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


entityWriters : RemoteData TVShow -> Metadata -> Html Msg
entityWriters tvShow metadata =
    let
        writers =
            if metadata.typ == "movie" then
                metadata.writers

            else
                case tvShow of
                    Just (Ok show) ->
                        show.info.writers

                    _ ->
                        []
    in
    if List.isEmpty writers then
        null

    else
        view [ style { flexDirection = "row" } ]
            [ text [ style { color = "gray", fontSize = 11 }, numberOfLines 1 ]
                [ str <|
                    "Writers: "
                        ++ String.join ", " (List.map .tag writers)
                ]
            ]


entityDirectors : RemoteData TVShow -> Metadata -> Html Msg
entityDirectors tvShow metadata =
    let
        directors =
            if metadata.typ == "movie" then
                metadata.directors

            else
                case tvShow of
                    Just (Ok show) ->
                        show.info.directors

                    _ ->
                        []
    in
    if List.isEmpty directors then
        null

    else
        view [ style { flexDirection = "row" } ]
            [ text [ style { color = "gray", fontSize = 11 }, numberOfLines 1 ]
                [ str <|
                    "Directors: "
                        ++ String.join ", " (List.map .tag directors)
                ]
            ]


entityCasts : RemoteData TVShow -> Metadata -> Html Msg
entityCasts tvShow metadata =
    let
        casts =
            if metadata.typ == "movie" then
                metadata.roles

            else
                case tvShow of
                    Just (Ok show) ->
                        show.info.roles

                    _ ->
                        []
    in
    if List.isEmpty casts then
        null

    else
        view [ style { flexDirection = "row" } ]
            [ text [ style { color = "gray", fontSize = 11 }, numberOfLines 1 ]
                [ str <|
                    "Casts: "
                        ++ String.join ", " (List.map .tag casts)
                ]
            ]


episodeTitle ep =
    "S" ++ String.fromInt ep.parentIndex ++ ":E" ++ String.fromInt ep.index ++ " " ++ ep.title


entityInfo : Bool -> RemoteData TVShow -> Metadata -> Html Msg
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

        { directors, casts } =
            if metadata.typ == "movide" then
                { directors = metadata.directors
                , casts = metadata.roles
                }

            else
                case tvShow of
                    Just (Ok show) ->
                        { directors = show.info.directors
                        , casts = show.info.roles
                        }

                    _ ->
                        { directors = [], casts = [] }
    in
    fragment []
        [ entityTitle title
        , entityGeneral tvShow metadata
        , if showPlayButton then
            entityPlayButton metadata isContinueWatching

          else
            null
        , if String.isEmpty label then
            null

          else
            entityLabel label
        , if showProgress then
            entityProgressBar (Maybe.withDefault metadata.duration metadata.viewOffset) metadata.duration label

          else
            null
        , entitySummary tvShow metadata
        , entityDirectors tvShow metadata
        , entityWriters tvShow metadata
        , entityCasts tvShow metadata
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
            , renderItem = \{ item } -> episodeView client item model.screenMetrics
            , getItemLayout = Nothing
            }
            [ listHeaderNode <| entityInfo isContinueWatching tvShow metadata
            , listFooterNode bottomPadding
            , contentContainerStyle { paddingHorizontal = 10 }
            , initialNumToRender 4
            ]
        ]
