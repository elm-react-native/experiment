module Model exposing (Dialogue, HomeModel, LibrarySection, Model(..), Msg(..), PlaybackSpeed, PlaybackState(..), RemoteData, ScreenLockState(..), SeekStage(..), TVSeason, TVShow, VideoPlayer, VideoPlayerControlAction(..), containsSubtitle, dialogueDecoder, findSeason, findTVShowByEpisodeRatingKey, initHomeModel, initialVideoPlayer, isVideoUrlReady, playbackSpeedDecoder, playbackSpeedEncode, playbackSpeedList, playbackSpeedToRate, updateSelectedSeason, updateTVShow)

import Api exposing (Account, Client, Library, Metadata, Section, initialMetadata)
import Browser.Navigation as N
import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import ReactNative.Animated as Animated
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import SignInModel exposing (SignInModel, SignInMsg)
import Time
import Utils exposing (containsItem)


type alias RemoteData data =
    Maybe (Result Http.Error data)


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


type alias VideoPlayer =
    { sessionId : String
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
    , haveSubtitle : Bool
    }


type ScreenLockState
    = Unlocked
    | Locked
    | ConfirmUnlock


initialVideoPlayer : VideoPlayer
initialVideoPlayer =
    { sessionId = ""
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
    , haveSubtitle = False
    }


type alias HomeModel =
    { continueWatching : RemoteData (List Metadata)
    , librariesRecentlyAdded : Dict String (Result Http.Error (List Metadata))
    , librariesDetails : Dict String (Result Http.Error (List Metadata))
    , libraries : List Library
    , tvShows : Dict String (Result Http.Error TVShow)
    , client : Client
    , account : Maybe Account
    , navKey : N.Key
    , videoPlayer : VideoPlayer
    , refreshing : Bool
    , screenMetrics : DisplayMetrics
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
    , screenMetrics = Dimensions.initialDisplayMetrics
    }


isVideoUrlReady : VideoPlayer -> Bool
isVideoUrlReady videoPlayer =
    not <| String.isEmpty videoPlayer.sessionId


type Model
    = Initial N.Key
    | SignIn SignInModel
    | Home HomeModel


type alias Dialogue =
    { start : Int
    , end : Int
    , text : String
    }


dialogueDecoder : Decoder Dialogue
dialogueDecoder =
    Decode.map3 Dialogue
        (Decode.field "start" Decode.int)
        (Decode.field "end" Decode.int)
        (Decode.field "text" Decode.string)


type SeekStage
    = SeekStart
    | Seeking
    | SeekRelease
    | SeekEnd


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
    | ChangeSubtitle Bool
    | ExtendTimeout


type Msg
    = NoOp
    | SignInMsg SignInMsg
    | GotSavedClient (Maybe Client)
    | GotAccount (Result Http.Error Account)
    | GotLibraries (Result Http.Error (List Library))
    | GotLibraryDetail String (Result Http.Error (List Metadata))
    | GotLibraryRecentlyAdded String (Result Http.Error (List Metadata))
    | GotContinueWatching (Result Http.Error (List Metadata))
    | GotTVShow String (Result Http.Error TVShow)
    | GotNextEpisode String (Result Http.Error ( TVShow, Maybe Metadata ))
    | GotStreams String (Result Http.Error Metadata)
    | GotEpisodes String String (Result Http.Error (List Metadata))
    | GotoAccount
    | GotoEntity Bool Metadata
    | ChangeSeason String String
    | PlayVideo Metadata
    | PlayVideoError String
    | GotPlaySessionId String
    | GotScreenMetrics Dimensions.DisplayMetrics
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


updateTVShow : (TVShow -> TVShow) -> String -> Dict String (Result Http.Error TVShow) -> Dict String (Result Http.Error TVShow)
updateTVShow fn showId tvShows =
    case Dict.get showId tvShows of
        Just (Ok show) ->
            Dict.insert showId (Ok <| fn show) tvShows

        _ ->
            tvShows


updateSelectedSeason seasonId showId tvShows =
    updateTVShow (\sh -> { sh | selectedSeason = seasonId }) showId tvShows


findTVShowByEpisodeRatingKey : String -> Dict String (Result Http.Error TVShow) -> Maybe ( TVShow, TVSeason, Metadata )
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


containsSubtitle metadata =
    let
        hasStream part =
            containsItem (\{ streamType, codec } -> streamType == 3 && codec /= "vobsub") part.streams

        hasMedia media =
            containsItem hasStream media.parts
    in
    containsItem hasMedia metadata.medias
