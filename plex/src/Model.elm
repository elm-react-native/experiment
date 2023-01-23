module Model exposing (HomeModel, LibrarySection, Model(..), Msg(..), RemoteData, TVSeason, TVShow, VideoPlayer, findSeason, initHomeModel, initialVideoPlayer, isVideoUrlReady, updateSelectedSeason, updateTVShow)

import Api exposing (Account, Client, Library, Metadata, Section)
import Browser.Navigation as N
import Dict exposing (Dict)
import Http
import ReactNative.Dimensions as Dimensions
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
    , screenMetrics : Dimensions.DisplayMetrics
    , duration : Int
    , ratingKey : String
    , playbackTime : Int
    , isBuffering : Bool
    , initialPlaybackTime : Int
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
    }


initialVideoPlayer : VideoPlayer
initialVideoPlayer =
    { sessionId = ""
    , screenMetrics = Dimensions.initialDisplayMetrics
    , duration = 0
    , ratingKey = ""
    , playbackTime = 0
    , isBuffering = False
    , initialPlaybackTime = 0
    }


isVideoUrlReady : VideoPlayer -> Bool
isVideoUrlReady videoPlayer =
    (not <| String.isEmpty videoPlayer.sessionId)
        && (videoPlayer.screenMetrics /= Dimensions.initialDisplayMetrics)


type Model
    = Initial N.Key
    | SignIn SignInModel
    | Home HomeModel


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
    | GotEpisodes String String (Result Http.Error (List Metadata))
    | GotoAccount
    | GotoEntity Bool Metadata
    | ChangeSeason String String
    | PlayVideo String (Maybe Int) Int
    | PlayVideoError String
    | GotPlaySessionId String
    | GotScreenMetrics Dimensions.DisplayMetrics
    | StopPlayVideo
    | OnVideoBuffer Bool
    | OnVideoProgress Int
    | OnLeaveVideoScreen
    | SaveVideoPlayback Time.Posix
    | SignOut


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
