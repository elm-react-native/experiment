module Model exposing (..)

import Api exposing (Account, Client, Metadata, Section)
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


type alias HomeModel =
    { sections : RemoteData (List Section)
    , tvShows : Dict String (Result Http.Error TVShow)
    , client : Client
    , account : Account
    , navKey : N.Key
    }


type Model
    = Initial N.Key
    | SignIn SignInModel
    | Home HomeModel


type Msg
    = NoOp
    | GotoSignIn
    | SignInInputAddress String
    | SignInInputToken String
    | SignInSubmit Client
    | SignInSubmitResponse (Result Http.Error Account)
    | ReloadSections
    | GotSections (Result Http.Error (List Section))
    | GotTVShow String (Result Http.Error TVShow)
    | GotEpisodes String String (Result Http.Error (List Metadata))
    | DismissKeyboard
    | ShowSection String
    | ShowEntity String String
    | GotoAccount
    | GotoEntity Bool Metadata
    | ChangeSeason String String
    | ShowPicker (List ( String, Msg ))
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
