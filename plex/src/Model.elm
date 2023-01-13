module Model exposing (..)

import Api exposing (Account, Client, Library, Metadata, Section)
import Browser.Navigation as N
import Dict exposing (Dict)
import Http


type alias SignInModel =
    { client : Client, navKey : N.Key, submitting : Bool }


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


type alias HomeModel =
    { sections : RemoteData (List Section)
    , tvShows : Dict String (Result Http.Error TVShow)
    , client : Client
    , account : Account
    , navKey : N.Key
    , libraries : Dict String LibrarySection
    }


type Model
    = Initial N.Key
    | SignIn SignInModel
    | Home HomeModel


type Msg
    = NoOp
    | GotoSignIn (Maybe Client)
    | SignInInputAddress String
    | SignInInputToken String
    | SignInSubmit Client
    | SignInSubmitResponse (Result Http.Error Account)
    | ReloadSections
    | GotSections (Result Http.Error (List Section))
    | GotLibraries (Result Http.Error (List Library))
    | GotLibrarySection String LibrarySection
    | GotTVShow String (Result Http.Error TVShow)
    | GotEpisodes String String (Result Http.Error (List Metadata))
    | DismissKeyboard
    | ShowSection String
    | ShowEntity String String
    | GotoAccount
    | GotoEntity Bool Metadata
    | ChangeSeason String String
    | ShowPicker (List ( String, Msg ))
    | PlayVideo String
    | PlayVideoError String
    | StopPlayVideo
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
