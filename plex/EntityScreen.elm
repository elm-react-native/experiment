module EntityScreen exposing (..)

import Api exposing (Client, Metadata)
import Components exposing (bottomPadding, chip, progressBar, vidoePlayContainer)
import Dict
import Html exposing (Html)
import Json.Decode as Decode
import Model exposing (..)
import ReactNative
    exposing
        ( activityIndicator
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
        , imageStyle
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
                { uri = Api.pathToAuthedUrl thumb client
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


heroInfo : Metadata -> Html msg
heroInfo metadata =
    view [ style { flexDirection = "row", marginTop = 10 } ]
        [ text
            [ style
                { color = "white"
                , fontSize = 12
                , marginRight = 4
                }
            ]
            [ str <| String.slice 0 4 metadata.originallyAvailableAt ]
        , if String.isEmpty metadata.contentRating then
            null

          else
            chip metadata.contentRating
        , ratingView metadata.audienceRating metadata.audienceRatingImage
        , if metadata.typ == "show" || metadata.typ == "season" || metadata.duration == 0 then
            null

          else
            text [ style { color = "white", marginLeft = 4, fontSize = 12 } ] [ str <| formatDuration metadata.duration ]
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
    view [ style { flexDirection = "row", marginLeft = 4 } ]
        [ image
            [ source src
            , style size
            ]
            []
        , text [ style { color = "white", fontSize = 12 } ] [ str <| percentFloat <| score / 10 ]
        ]


heroPlayButton : Bool -> Html msg
heroPlayButton isContinueWatching =
    touchableOpacity []
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


heroSummary : String -> Html msg
heroSummary summary =
    text
        [ style
            { fontSize = 12
            , color = "white"
            , marginTop = 5
            }
        ]
        [ str summary ]


episodesView : List Metadata -> Api.Client -> Html Msg
episodesView eps client =
    view
        []
        (List.map
            (\ep ->
                view []
                    [ view [ style { flexDirection = "row", marginTop = 15, alignItems = "center" } ]
                        [ imageBackground
                            [ source
                                { uri = Api.pathToAuthedUrl ep.thumb client
                                , width = 720
                                , height = 404
                                , cache = "force-cache"
                                }
                            , style { width = 112, height = 63, justifyContent = "flex-end" }
                            , imageStyle { borderRadius = 4, resizeMode = "contain" }
                            ]
                            [ vidoePlayContainer (Decode.succeed NoOp)
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
            )
            eps
        )


seasonView : Int -> TVShow -> Html Msg
seasonView selectedSeasonIndex show =
    touchableOpacity
        [ onPress <|
            Decode.succeed
                (ShowPicker
                    (List.map
                        (\sz ->
                            ( "Season" ++ String.fromInt sz.info.index, ChangeSeason show.info.ratingKey sz.info.ratingKey )
                        )
                        show.seasons
                    )
                )
        , style
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
            [ str <| "Season " ++ String.fromInt selectedSeasonIndex ]
        , ionicon "chevron-down-outline" [ size 12, color "white" ]
        ]


seasonsView : TVShow -> Api.Client -> Html Msg
seasonsView show client =
    case findSeason show.selectedSeason show of
        Just selectedSeason ->
            view [ style { marginTop = 20 } ]
                [ seasonView selectedSeason.info.index show
                , case selectedSeason.episodes of
                    Just (Ok eps) ->
                        episodesView eps client

                    Just (Err _) ->
                        view []
                            [ text [] [ str "Load episodes error" ]
                            ]

                    _ ->
                        view
                            [ style
                                { height = 50
                                , justifyContent = "center"
                                , alignItems = "center"
                                }
                            ]
                            [ activityIndicator [] [] ]
                ]

        _ ->
            null


entityScreen : HomeModel -> { isContinueWatching : Bool, metadata : Metadata } -> Html Msg
entityScreen model { isContinueWatching, metadata } =
    let
        client =
            model.client

        { title, label, showProgress, showPlayButton, showId, showEpisodes } =
            case metadata.typ of
                "episode" ->
                    { title = metadata.grandparentTitle
                    , showId = metadata.grandparentRatingKey
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index ++ " " ++ metadata.title
                    , showProgress = isContinueWatching
                    , showPlayButton = True
                    , showEpisodes = True
                    }

                "season" ->
                    { title = metadata.parentTitle
                    , showId = metadata.parentRatingKey
                    , label = "S" ++ String.fromInt metadata.index
                    , showProgress = False
                    , showPlayButton = False
                    , showEpisodes = True
                    }

                "show" ->
                    { title = metadata.title
                    , showId = metadata.ratingKey
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , showEpisodes = True
                    }

                "movie" ->
                    { title = metadata.title
                    , showId = ""
                    , label = ""
                    , showProgress = isContinueWatching
                    , showPlayButton = True
                    , showEpisodes = False
                    }

                _ ->
                    { title = metadata.title
                    , showId = ""
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , showEpisodes = False
                    }
    in
    view
        [ style
            { backgroundColor = Theme.backgroundColor
            , width = "100%"
            , height = "100%"
            }
        ]
        [ heroImage metadata.thumb client
        , scrollView
            [ contentContainerStyle { paddingHorizontal = 10 } ]
            [ heroTitle title
            , heroInfo metadata
            , if showPlayButton then
                heroPlayButton isContinueWatching

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
            , heroSummary metadata.summary
            , if showEpisodes then
                case Dict.get showId model.tvShows of
                    Just (Ok show) ->
                        seasonsView show client

                    Just (Err _) ->
                        view [ style { marginTop = 20 } ]
                            [ text [] [ str "Load show error" ]
                            ]

                    _ ->
                        view
                            [ style
                                { height = 50
                                , justifyContent = "center"
                                , alignItems = "center"
                                , marginTop = 20
                                }
                            ]
                            [ activityIndicator [] [] ]

              else
                null
            , bottomPadding
            ]
        ]
