module Model exposing (ExternalSubtitle, ExternalSubtitleStatus(..), HomeModel, HomeMsg(..), LibrarySection, Model(..), Msg(..), PlaybackSpeed, PlaybackState(..), RemoteData, ScreenLockState(..), SearchSubtitle, SeekStage(..), TVSeason, TVShow, VideoPlayer, VideoPlayerControlAction(..), episodeTitle, filterMediaStream, findSeason, findTVShowByEpisodeRatingKey, getFirstPartId, getSelectedSubtitleStream, initHomeModel, initialVideoPlayer, isVideoUrlReady, playbackSpeedDecoder, playbackSpeedEncode, playbackSpeedList, playbackSpeedToRate, setExternalSubtitleStatus, updateEpisode, updateSelectedSeason, updateTVShow)

import Browser.Navigation as N
import Client exposing (Client)
import Dict exposing (Dict)
import Dto exposing (Account, Dialogue, Library, MediaStream, Metadata, Response, Section, initialMetadata)
import Http
import Json.Decode as Decode exposing (Decoder)
import ReactNative.Animated as Animated
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import Set exposing (Set)
import SignInModel exposing (SignInModel, SignInMsg)
import Time
import Utils exposing (findItem)


type alias RemoteData data =
    Maybe (Response data)


type alias TVShow =
    { info : Metadata
    , seasons : List TVSeason
    , selectedSeason : String
    }


type alias TVSeason =
    { info : Metadata
    , episodes : RemoteData (List Metadata)
    }


type alias LibrarySection =
    { info : Library, data : RemoteData (List Metadata) }


type PlaybackState
    = Playing
    | Paused
    | Stopped


type ExternalSubtitleStatus
    = Searched
    | Downloading
    | Downloaded


type alias ExternalSubtitle =
    { stream : MediaStream, status : ExternalSubtitleStatus }


type alias SearchSubtitle =
    { items : RemoteData (List ExternalSubtitle)
    , open : Bool
    , language : String
    , title : String
    }


type alias VideoPlayer =
    { sessionId : String
    , session : String
    , playbackTime : Int
    , playbackSpeed : PlaybackSpeed
    , isBuffering : Bool
    , seekTime : Int
    , subtitleSeekTime : Int
    , metadata : Metadata
    , showControls : Bool
    , seeking : Bool
    , state : PlaybackState
    , subtitle : List Dialogue
    , timeToHideControls : Maybe Int
    , playerControlsAnimatedValue : Animated.Value
    , hidingControls : Bool
    , screenLock : ScreenLockState
    , resizeMode : String
    , showSubtitle : Bool
    , selectedSubtitle : Int
    , selectedSeasonKey : String
    , episodesOpen : Bool
    , searchSubtitle : SearchSubtitle
    }


type ScreenLockState
    = Unlocked
    | Locked
    | ConfirmUnlock


initialSearchSubtitle : SearchSubtitle
initialSearchSubtitle =
    { open = False, language = "", items = Nothing, title = "" }


initialVideoPlayer : VideoPlayer
initialVideoPlayer =
    { sessionId = ""
    , session = ""
    , playbackTime = 0
    , isBuffering = False
    , seekTime = 0
    , subtitleSeekTime = 0
    , metadata = initialMetadata
    , showControls = False
    , seeking = False
    , state = Stopped
    , subtitle = []
    , timeToHideControls = Nothing
    , playerControlsAnimatedValue = Animated.create 0
    , hidingControls = False
    , screenLock = Unlocked
    , resizeMode = "cover"
    , playbackSpeed = Normal
    , showSubtitle = True
    , selectedSubtitle = 0
    , selectedSeasonKey = ""
    , episodesOpen = False
    , searchSubtitle = initialSearchSubtitle
    }


type alias HomeModel =
    { continueWatching : RemoteData (List Metadata)
    , librariesRecentlyAdded : Dict String (Response (List Metadata))
    , librariesDetails : Dict String (Response (List Metadata))
    , libraries : List Library
    , tvShows : Dict String (Response TVShow)
    , client : Client
    , account : Maybe Account
    , navKey : N.Key
    , videoPlayer : VideoPlayer
    , refreshing : Bool
    }


initHomeModel : Client -> N.Key -> HomeModel
initHomeModel client navKey =
    { continueWatching = Nothing
    , librariesRecentlyAdded = Dict.empty
    , librariesDetails = Dict.empty
    , libraries = []
    , account = Nothing
    , client = client
    , tvShows = Dict.empty
    , navKey = navKey
    , videoPlayer = initialVideoPlayer
    , refreshing = False
    }


isVideoUrlReady : VideoPlayer -> Bool
isVideoUrlReady videoPlayer =
    not (String.isEmpty videoPlayer.sessionId || String.isEmpty videoPlayer.session)


type Model
    = Initial N.Key
    | SignIn SignInModel
    | Home HomeModel


type SeekStage
    = SeekStart
    | Seeking
    | SeekRelease


type PlaybackSpeed
    = VerySlow
    | Slow
    | Normal
    | Fast
    | VeryFast


playbackSpeedList =
    [ VerySlow, Slow, Normal, Fast, VeryFast ]


playbackSpeedToRate : PlaybackSpeed -> Float
playbackSpeedToRate speed =
    case speed of
        VerySlow ->
            0.5

        Slow ->
            0.75

        Normal ->
            1.0

        Fast ->
            1.25

        VeryFast ->
            1.5


playbackSpeedEncode : PlaybackSpeed -> String
playbackSpeedEncode speed =
    case speed of
        VerySlow ->
            "0.5x"

        Slow ->
            "0.75x"

        Normal ->
            "1x"

        Fast ->
            "1.25x"

        VeryFast ->
            "1.5x"


playbackSpeedDecoder : String -> PlaybackSpeed
playbackSpeedDecoder s =
    case s of
        "0.5x" ->
            VerySlow

        "0.75x" ->
            Slow

        "1x" ->
            Normal

        "1.25x" ->
            Fast

        "1.5x" ->
            VeryFast

        _ ->
            Normal


type VideoPlayerControlAction
    = TogglePlay
    | SeekAction SeekStage Int
    | NextEpisode
    | ChangeScreenLock ScreenLockState
    | ChangeResizeMode String
    | ChangeSpeed PlaybackSpeed
    | ChangeSubtitle Int Int
    | SetEpisodesOpen Bool
    | SetSearchSubtitleOpen Bool
    | SendSearchSubtitle String
    | GotSearchSubtitle (Response (List MediaStream))
    | ApplySubtitle String
    | ChangeSearchSubtitleLanguage String
    | ApplySubtitleResp String (Response ())
    | ExtendTimeout


type Msg
    = NoOp
    | SignInMsg SignInMsg
    | GotSavedClient (Maybe Client)
    | HomeMsg HomeMsg


type HomeMsg
    = HomeNoOp
    | GotAccount (Response Account)
    | GotLibraries (Response (List Library))
    | GotLibraryDetail String (Response (List Metadata))
    | GotLibraryRecentlyAdded String (Response (List Metadata))
    | GotContinueWatching (Response (List Metadata))
    | GotTVShow String (Response TVShow)
    | GotNextEpisode String (Response ( TVShow, Maybe Metadata ))
    | GotStreams String (Response Metadata)
    | GotEpisodes String String (Response (List Metadata))
    | GotoAccount
    | GotoEntity Bool Metadata
    | ChangeSeason String String
    | PlayVideo Metadata
    | PlayVideoError String
    | GotPlaySessionId String
    | GotPlaySession String
    | StopPlayVideo
    | OnVideoEnd
    | OnVideoBuffer Bool
    | OnVideoProgress Int
    | OnLeaveVideoScreen
    | SaveVideoPlayback Time.Posix
    | SignOut
    | RefreshHomeScreen
    | GotSubtitle (List Dialogue)
    | ToggleVideoPlayerControls
    | HideVideoPlayerControls Int
    | UpdateTimeToHideControls Int
    | VideoPlayerControl VideoPlayerControlAction
    | HideVideoPlayerControlsAnimationFinish
    | SubtitleChanged
    | RestartPlaySession Bool String
    | ScanLibrary String
    | ViewLibrary String


{-| fallback to first season when not find, return `Nothing` when seasons is empty
-}
findSeason : String -> TVShow -> Maybe TVSeason
findSeason seasonId { seasons } =
    let
        find xs =
            case xs of
                x :: xs2 ->
                    if x.info.ratingKey == seasonId then
                        Just x

                    else
                        find xs2

                _ ->
                    Nothing
    in
    case find seasons of
        Nothing ->
            List.head seasons

        sz ->
            sz


updateTVShow : (TVShow -> TVShow) -> String -> Dict String (Response TVShow) -> Dict String (Response TVShow)
updateTVShow fn showId tvShows =
    case Dict.get showId tvShows of
        Just (Ok show) ->
            Dict.insert showId (Ok <| fn show) tvShows

        _ ->
            tvShows


updateSelectedSeason seasonId showId tvShows =
    updateTVShow (\sh -> { sh | selectedSeason = seasonId }) showId tvShows


findTVShowByEpisodeRatingKey : String -> Dict String (Response TVShow) -> Maybe ( TVShow, TVSeason, Metadata )
findTVShowByEpisodeRatingKey ratingKey tvShows =
    tvShows
        |> Dict.values
        |> List.filterMap
            (\tvShow ->
                case tvShow of
                    Ok show ->
                        show.seasons
                            |> List.filterMap
                                (\season ->
                                    case season.episodes of
                                        Just (Ok episodes) ->
                                            episodes
                                                |> List.filter (\ep -> ep.ratingKey == ratingKey)
                                                |> List.head
                                                |> Maybe.map (\ep -> ( show, season, ep ))

                                        _ ->
                                            Nothing
                                )
                            |> List.head

                    _ ->
                        Nothing
            )
        |> List.head


updateSeason : (TVSeason -> TVSeason) -> String -> TVShow -> TVShow
updateSeason f seasonId tvShow =
    { tvShow
        | seasons =
            List.map
                (\s ->
                    if seasonId == s.info.ratingKey then
                        f s

                    else
                        s
                )
                tvShow.seasons
    }


updateEpisode : Metadata -> Dict String (Response TVShow) -> Dict String (Response TVShow)
updateEpisode metadata =
    updateTVShow
        (updateSeason
            (\season ->
                { season
                    | episodes =
                        case season.episodes of
                            Just (Ok episodes) ->
                                Just <|
                                    Ok <|
                                        List.map
                                            (\ep ->
                                                if ep.ratingKey == metadata.ratingKey then
                                                    metadata

                                                else
                                                    ep
                                            )
                                            episodes

                            otherwise ->
                                otherwise
                }
            )
            metadata.parentRatingKey
        )
        metadata.grandparentRatingKey


getSelectedSubtitleStream : Metadata -> Maybe MediaStream
getSelectedSubtitleStream metadata =
    List.head <| filterMediaStream (\s -> s.streamType == 3 && s.selected) metadata


episodeTitle ep =
    "S" ++ String.fromInt ep.parentIndex ++ ":E" ++ String.fromInt ep.index ++ " " ++ "“" ++ ep.title ++ "”"


filterMediaStream : (MediaStream -> Bool) -> Metadata -> List MediaStream
filterMediaStream pred metadata =
    let
        findStreams part =
            List.filter pred part.streams

        findParts media =
            List.concatMap findStreams media.parts
    in
    List.concatMap findParts metadata.medias


getFirstPartId : Metadata -> Maybe Int
getFirstPartId metadata =
    case metadata.medias of
        media :: _ ->
            case media.parts of
                part :: _ ->
                    Just part.id

                _ ->
                    Nothing

        _ ->
            Nothing


setExternalSubtitleStatus : String -> ExternalSubtitleStatus -> SearchSubtitle -> SearchSubtitle
setExternalSubtitleStatus key status searchSubtitle =
    { searchSubtitle
        | items =
            case searchSubtitle.items of
                Just (Ok items) ->
                    Just
                        (Ok <|
                            List.map
                                (\s ->
                                    if key == s.stream.key then
                                        { stream = s.stream, status = status }

                                    else
                                        s
                                )
                                items
                        )

                _ ->
                    searchSubtitle.items
    }
