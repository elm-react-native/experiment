module EntityScreen exposing (..)

import Api exposing (Metadata)
import Components exposing (progressBar, vidoePlayContainer)
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
        , size
        , source
        , style
        , title
        )
import Theme
import Utils exposing (formatDuration, percentFloat)


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
        [ image
            [ source
                { uri = Api.pathToAuthedUrl metadata.thumb client
                , width = 480
                , height = 719
                }
            , style { height = 210, width = "100%" }
            ]
            []
        , scrollView
            [ contentContainerStyle
                { paddingHorizontal = 10
                }
            ]
            [ text
                [ style
                    { fontSize = 18
                    , fontWeight = "bold"
                    , color = "white"
                    , marginTop = 10
                    }
                ]
                [ str title ]
            , view [ style { flexDirection = "row", marginTop = 10 } ]
                [ text
                    [ style
                        { color = "white"
                        , fontSize = 12
                        }
                    ]
                    [ str <| String.slice 0 4 metadata.originallyAvailableAt ]
                , if String.isEmpty metadata.contentRating then
                    null

                  else
                    view
                        [ style
                            { backgroundColor = "gray"
                            , borderRadius = 2
                            , padding = 2
                            , marginLeft = 2
                            , alignItems = "center"
                            , justifyContent = "center"
                            }
                        ]
                        [ text
                            [ style
                                { color = "white"
                                , fontSize = 8
                                , fontWeight = "bold"
                                }
                            ]
                            [ str metadata.contentRating
                            ]
                        ]
                , if metadata.duration == 0 then
                    null

                  else
                    text [ style { color = "white", marginLeft = 2, fontSize = 12 } ] [ str <| formatDuration metadata.duration ]
                ]
            , if showPlayButton then
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

              else
                null
            , if String.isEmpty label then
                null

              else
                text
                    [ style
                        { color = "white"
                        , fontWeight = "bold"
                        , fontSize = 15
                        , marginTop = 10
                        }
                    ]
                    [ str label ]
            , if showProgress then
                let
                    progress =
                        toFloat metadata.viewOffset / toFloat metadata.duration

                    remainingDuration =
                        formatDuration (metadata.duration - metadata.viewOffset) ++ " remaining"
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
                    [ view
                        [ style
                            { backgroundColor = "gray"
                            , height = 3
                            , flexGrow = 1
                            , marginRight = 10
                            }
                        ]
                        [ view
                            [ style
                                { width = percentFloat progress
                                , backgroundColor = Theme.themeColor
                                , height = "100%"
                                }
                            ]
                            []
                        ]
                    , text [ style { color = "gray", fontSize = 9 } ] [ str remainingDuration ]
                    ]

              else
                null
            , text
                [ style
                    { fontSize = 12
                    , color = "white"
                    , marginTop = 5
                    }
                ]
                [ str metadata.summary ]
            , if showEpisodes then
                case Dict.get showId model.tvShows of
                    Just (Ok show) ->
                        case findSeason show.selectedSeason show of
                            Just selectedSeason ->
                                view [ style { marginTop = 20 } ]
                                    [ touchableOpacity
                                        [ onPress <|
                                            Decode.succeed
                                                (ShowPicker
                                                    (List.map
                                                        (\sz ->
                                                            ( "Season" ++ String.fromInt sz.info.index, ChangeSeason showId sz.info.ratingKey )
                                                        )
                                                        show.seasons
                                                    )
                                                )
                                        , style { flexDirection = "row", alignItems = "center" }
                                        ]
                                        [ text
                                            [ style
                                                { fontWeight = "bold"
                                                , color = "white"
                                                , marginRight = 5
                                                }
                                            ]
                                            [ str <| "Season " ++ String.fromInt selectedSeason.info.index ]
                                        , ionicon "chevron-down-outline" [ size 12, color "white" ]
                                        ]
                                    , case selectedSeason.episodes of
                                        Just (Ok eps) ->
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
                                                                        }
                                                                    , style { width = 122, height = 65, justifyContent = "flex-end" }
                                                                    , imageStyle { borderRadius = 4, resizeMode = "contain" }
                                                                    ]
                                                                    [ vidoePlayContainer (Decode.succeed NoOp)
                                                                    , if ep.viewOffset <= 0 then
                                                                        null

                                                                      else
                                                                        progressBar [ style { width = 116, marginHorizontal = 3 } ] (toFloat ep.viewOffset / toFloat ep.duration)
                                                                    ]
                                                                , view [ style { marginLeft = 3 } ]
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
            , view [ style { height = 70, width = "100%" } ] []
            ]
        ]
