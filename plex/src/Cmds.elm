module Cmds exposing (..)

import Api
import Client exposing (Client)
import Dto exposing (..)
import Http
import Model exposing (..)
import Process
import ReactNative.Animated as Animated
import ReactNative.Easing as Easing
import Task exposing (Task)
import Time
import Utils


hijackUnauthorizedError : (Response a -> HomeMsg) -> (Response a -> HomeMsg)
hijackUnauthorizedError tagger =
    \resp ->
        case resp of
            Err (Http.BadStatus 401) ->
                SignOut

            _ ->
                tagger resp


getAccount : Client -> Cmd HomeMsg
getAccount =
    Api.getAccount (hijackUnauthorizedError GotAccount)


getLibraries : Client -> Cmd HomeMsg
getLibraries =
    Api.getLibraries (hijackUnauthorizedError GotLibraries)


getContinueWatching : Client -> Cmd HomeMsg
getContinueWatching =
    Api.getContinueWatching (hijackUnauthorizedError GotContinueWatching)


getLibraryDetails : Client -> String -> Cmd HomeMsg
getLibraryDetails client key =
    Api.getLibrary key (hijackUnauthorizedError <| GotLibraryDetail key) client


getLibraryRecentlyAdded : Client -> String -> Cmd HomeMsg
getLibraryRecentlyAdded client key =
    Api.getLibraryRecentlyAdded key
        (hijackUnauthorizedError
            (\section ->
                GotLibraryRecentlyAdded key (Result.map .data section)
            )
        )
        client


getTVShowTask id seasonId client =
    Task.map2
        (\show seasons ->
            { info = show
            , seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons
            , selectedSeason = seasonId
            }
        )
        (Api.getMetadata id client)
        (Api.getMetadataChildren id client)


isScanning key libs =
    case Utils.findItem (\lib -> lib.key == key) libs of
        Just lib ->
            lib.scanning

        _ ->
            False


waitScanningFinish : String -> Client -> Task Http.Error (List Library)
waitScanningFinish key client =
    Process.sleep 2000
        |> Task.andThen (\_ -> Api.getLibrariesTask client)
        |> Task.andThen
            (\libs ->
                if isScanning key libs then
                    waitScanningFinish key client

                else
                    Task.succeed libs
            )


scanLibrary : String -> Client -> Cmd HomeMsg
scanLibrary key client =
    Api.scanLibrary key client
        |> Task.andThen (\_ -> waitScanningFinish key client)
        |> Task.attempt (hijackUnauthorizedError GotLibraries)


updateEpisodes : String -> Response (List Metadata) -> List TVSeason -> List TVSeason
updateEpisodes seasonId resp seasons =
    List.map
        (\season ->
            if season.info.ratingKey == seasonId then
                { season | episodes = Just resp }

            else
                season
        )
        seasons


getTVShowAndEpisodes : String -> String -> Client -> Task Http.Error TVShow
getTVShowAndEpisodes parentRatingKey grandparentRatingKey client =
    Task.map2
        (\tvShow episodes ->
            { tvShow
                | seasons =
                    updateEpisodes parentRatingKey (Ok episodes) tvShow.seasons
            }
        )
        (getTVShowTask grandparentRatingKey parentRatingKey client)
        (Api.getMetadataChildren parentRatingKey client)


getNextEpisodeOfTVShow : String -> String -> TVShow -> Maybe Metadata
getNextEpisodeOfTVShow ratingKey parentRatingKey tvShow =
    let
        findNext pred items =
            case items of
                x :: y :: rest ->
                    if pred x then
                        Just y

                    else
                        findNext pred (y :: rest)

                _ ->
                    Nothing
    in
    case findSeason parentRatingKey tvShow of
        Just season ->
            case season.episodes of
                Just (Ok episodes) ->
                    findNext (\ep -> ep.ratingKey == ratingKey) episodes

                _ ->
                    Nothing

        _ ->
            Nothing


getTVShowAndNextEpisode : String -> String -> String -> Client -> Cmd HomeMsg
getTVShowAndNextEpisode ratingKey parentRatingKey grandparentRatingKey client =
    getTVShowAndEpisodes parentRatingKey grandparentRatingKey client
        |> Task.map (\tvShow -> ( tvShow, getNextEpisodeOfTVShow ratingKey parentRatingKey tvShow ))
        |> Task.attempt (hijackUnauthorizedError <| GotNextEpisode grandparentRatingKey)


getTVShow : String -> String -> Client -> Cmd HomeMsg
getTVShow id seasonId client =
    getTVShowTask id seasonId client
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow id)


getStreams : String -> Client -> Cmd HomeMsg
getStreams id client =
    Api.getMetadata id client
        |> Task.attempt (hijackUnauthorizedError <| GotStreams id)


getSeasons : Metadata -> String -> Client -> Cmd HomeMsg
getSeasons tvShowInfo seasonId client =
    Api.getMetadataChildren tvShowInfo.ratingKey client
        |> Task.map (\seasons -> { info = tvShowInfo, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
        |> Task.attempt (hijackUnauthorizedError <| GotTVShow tvShowInfo.ratingKey)


getEpisodes : String -> String -> Client -> Cmd HomeMsg
getEpisodes showId seasonId client =
    Api.getMetadataChildren seasonId client
        |> Task.attempt (hijackUnauthorizedError <| GotEpisodes showId seasonId)


selectSubtitle : String -> Int -> Int -> Client -> Cmd HomeMsg
selectSubtitle _ partId subtitleStreamId client =
    Api.selectSubtitle partId subtitleStreamId client
        |> Task.attempt (hijackUnauthorizedError <| always SubtitleChanged)


sendDecision newSession { metadata, sessionId } client =
    Api.sendDecision newSession metadata.ratingKey sessionId (always <| RestartPlaySession True newSession) client


savePlaybackTime : VideoPlayer -> Client -> Cmd HomeMsg
savePlaybackTime videoPlayer client =
    let
        state =
            case videoPlayer.state of
                Playing ->
                    "playing"

                Paused ->
                    "paused"

                Stopped ->
                    "stopped"
    in
    Api.playerTimeline
        { ratingKey = videoPlayer.metadata.ratingKey
        , state = state
        , time = videoPlayer.playbackTime
        , duration = videoPlayer.metadata.duration
        }
        (hijackUnauthorizedError <| always HomeNoOp)
        client


extendTimeToHideControls : Cmd HomeMsg
extendTimeToHideControls =
    Task.perform (\now -> UpdateTimeToHideControls <| Time.posixToMillis now + 5000) Time.now


hideVideoPlayerControlsAnimation : Animated.Value -> Cmd HomeMsg
hideVideoPlayerControlsAnimation animatedValue =
    animatedValue
        |> Animated.timing { toValue = 0, duration = 200, easing = Easing.cubic }
        |> Animated.start
        |> Task.perform (always HideVideoPlayerControlsAnimationFinish)


showVideoPlayerControlsAnimation : Animated.Value -> Cmd HomeMsg
showVideoPlayerControlsAnimation animatedValue =
    animatedValue
        |> Animated.timing { toValue = 1, duration = 200, easing = Easing.cubic }
        |> Animated.start
        |> Task.perform (always HomeNoOp)
