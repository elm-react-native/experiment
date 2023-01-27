module Model exposing (Dialogue, HomeModel, LibrarySection, Model(..), Msg(..), RemoteData, TVSeason, TVShow, VideoPlayer, findSeason, findTVShowByEpisodeRatingKey, initHomeModel, initialVideoPlayer, isVideoUrlReady, updateSelectedSeason, updateTVShow)

import Api exposing (Account, Client, Library, Metadata, Section, initialMetadata)
import Browser.Navigation as N
import Dict exposing (Dict)
import Http
import ReactNative.Dimensions as Dimensions exposing (DisplayMetrics)
import SignInModel exposing (SignInModel, SignInMsg)
import Time


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


type alias VideoPlayer =
    { sessionId : String
    , playbackTime : Int
    , isBuffering : Bool
    , seekTime : Int
    , metadata : Metadata
    , showControls : Bool
    , seeking : Bool
    , playing : Bool
    , subtitle : List Dialogue
    }


initialVideoPlayer : VideoPlayer
initialVideoPlayer =
    { sessionId = ""
    , playbackTime = 0
    , isBuffering = False
    , seekTime = 0
    , metadata = initialMetadata
    , showControls = False
    , seeking = False
    , playing = True
    , subtitle = []
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
    { id : Int
    , start : Int
    , end : Int
    , text : String
    }


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
    | ToggleVideoPlayerControls
    | HideVideoPlayerControls
    | OnVideoSeek Int
    | OnVideoSeeked
    | ChangeSeeking Bool Int
    | ChangePlaying Bool
    | GotSubtitle (List Dialogue)


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
