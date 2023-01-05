module Api exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Task exposing (Task)



--type alias MediaContainer metadata =
--    { size : Int -- The number of libraries.
--    , allowSync : Bool -- 1 - allow syncing content from this library.  0 - don't allow syncing content from this library.
--    , identifier : String -- The type of item.
--    , art : String -- Background artwork used to represent the library.
--    , librarySectionID : String -- The unique key associated with the library.
--    , librarySectionTitle : String -- The title of the library.
--    , librarySectionUUID : String -- Unique GUID identifier for the library.
--    , mediaTagPrefix : String -- Prefix for the media tag.
--    , medidTagVersion : Int -- Media tag version. Note: This could be a date and time value.
--    , thumb : String -- The thumbnail for the library.
--    , title1 : String -- The title of the library. Note: This appears to be internally created, and can't be changed by the server owner.
--    , title2 : String -- A descriptive title for the library.
--    , sortAsc : Bool -- 1 - the library is sorted in ascending order. 0 - the library is sorted in descending order.
--    , viewGroup : String -- The group type used to view the library.
--    , viewMode : Int -- Unknown integer value.
--    , nocache : Bool
--    , metadata : List metadata
--    }


type alias Library =
    { allowSync : Bool -- 1 - allow the items in the to be synced. 0 - do not allow the items in the library to be synced.
    , art : String -- The background artwork used to represent the library.
    , composite : String -- The composite image associated with the library.
    , filters : Bool -- 1 - allow library filters. 0 - do no allow library filters.
    , refreshing : Bool -- 1 - the library is refreshing the metadata. 0 - the library is not refreshing the metadata.
    , thumb : String -- The thumbnail for the library.
    , key : String -- The relative URL of the information for the library.
    , typ : String -- The type of item represented by this Directory element.
    , title : String -- The name of the library.
    , agent : String -- The agent used to set the metadata for the items in the library.
    , scanner : String -- The name of the scanner used to scan the library.
    , language : String -- The two-character language for the library.
    , uuid : String -- Unique identifier for the library.
    , updatedAt : Int -- The date and time the library was updated in the library.
    , createdAt : Int -- The date and time when the library was created.
    , scannedAt : Int -- The date and time when the library was last scanned
    , content : Bool
    , directory : Bool
    , contentChangedAt : Int -- The date and time when the library content was last changed.
    , hidden : Bool -- 1 - the library is hidden. 0 - the library is not hidden.
    , location : List Location
    }


type alias Location =
    { id : Int, path : String }



--type alias Hub =
--    { hubKey : String
--    , key : String
--    , title : String
--    , typ : String
--    , hubIdentifier : String
--    , context : String
--    , size : Int
--    , more : Bool
--    , style : String
--    , promoted : Bool
--    , metadata : List Metadata
--    }


type alias Metadata =
    { ratingKey : String --   A key associated with the item.
    , key : String -- The relative URL of the item information.
    , guid : String --    The unique identifier comprised of the Plex agent and item identifier for the agent.
    , studio : String --  The name of the item studio.
    , typ : String --    The type of media.
    , title : String --   The title of the item.
    , contentRating : String --   The content rating associated with the item.
    , summary : String -- A summary of the item.
    , rating : String --  The rating for the item.
    , audienceRating : String --  The audience rating for the item.
    , skipCount : String --   The skip count.
    , year : Int --    The year the item was released.
    , tagline : String -- The tagline associated with the item.
    , thumb : String --   The thumbnail for the item.
    , art : String -- The background artwork used to represent the item.
    , duration : Int --    The length of the item in milliseconds.
    , originallyAvailableAt : Int --   The original release date of the item.
    , addedAt : Int -- The date and time the item was added to the library.
    , updatedAt : Int --   The date and time the item was updated in the library.
    , audienceRatingImage : String -- The image associated with the audience rating.
    , chapterSource : String --   The chapter source type.
    , ratingImage : String -- The image associated with the rating.
    , media : List Media
    , originalTitle : String
    , includedAt : Int
    , index : Int
    , parentKey : String
    , parentRatingKey : String
    , parentTitle : String
    , parentYear : Int
    , parentThumb : String
    , parentTheme : String
    , parentGuid : String
    , parentIndex : Int
    , parentStudio : String
    , grandparentTitle : String
    , grandparentKey : String
    , grandparentRatingKey : String
    , grandparentGuid : String
    , grandparentThumb : String
    , grandparentArt : String
    , grandparentTheme : String
    , grandparentIndex : Int
    , grandparentStudio : String
    , genres : List Genre
    , directors : List Director
    , writers : List Writer
    , roles : List Role
    , ratings : List Rating
    , guids : List Guid
    , countries : List Country
    , primaryExtraKey : String
    , hasPremiumExtras : String
    , hasPremiumPrimaryExtra : String
    , lastViewedAt : Int
    , viewCount : Int
    , viewOffset : Int
    }


initialMetadata =
    { ratingKey = ""
    , key = ""
    , guid = ""
    , studio = ""
    , typ = ""
    , title = ""
    , contentRating = ""
    , summary = ""
    , rating = ""
    , audienceRating = ""
    , skipCount = ""
    , year = 0
    , tagline = ""
    , thumb = ""
    , art = ""
    , duration = 0
    , originallyAvailableAt = 0
    , addedAt = 0
    , updatedAt = 0
    , audienceRatingImage = ""
    , chapterSource = ""
    , ratingImage = ""
    , media = []
    , originalTitle = ""
    , includedAt = 0
    , index = 0
    , parentKey = ""
    , parentRatingKey = ""
    , parentTitle = ""
    , parentYear = 0
    , parentThumb = ""
    , parentTheme = ""
    , parentGuid = ""
    , parentIndex = 0
    , parentStudio = ""
    , grandparentTitle = ""
    , grandparentKey = ""
    , grandparentRatingKey = ""
    , grandparentGuid = ""
    , grandparentThumb = ""
    , grandparentArt = ""
    , grandparentTheme = ""
    , grandparentIndex = 0
    , grandparentStudio = ""
    , genres = []
    , directors = []
    , writers = []
    , roles = []
    , ratings = []
    , guids = []
    , countries = []
    , primaryExtraKey = ""
    , hasPremiumExtras = ""
    , hasPremiumPrimaryExtra = ""
    , lastViewedAt = 0
    , viewCount = 0
    , viewOffset = 0
    }


maybeWithDefault defaultValue decoder =
    Decode.map (Maybe.withDefault defaultValue) <| Decode.maybe decoder


maybeString =
    maybeWithDefault ""


maybeZero =
    maybeWithDefault 0


metadataDecoder : Decoder Metadata
metadataDecoder =
    Decode.map8
        (\ratingKey guid typ thumb title duration grandparentTitle viewOffset ->
            { initialMetadata
                | ratingKey = ratingKey
                , guid = guid
                , typ = typ
                , thumb = thumb
                , title = title
                , duration = duration
                , grandparentTitle = grandparentTitle
                , viewOffset = viewOffset
            }
        )
        (Decode.field "ratingKey" Decode.string)
        (Decode.field "guid" Decode.string)
        (Decode.field "type" Decode.string)
        (Decode.field "thumb" Decode.string)
        (maybeString <| Decode.field "title" Decode.string)
        (maybeZero <| Decode.field "duration" Decode.int)
        (maybeString <| Decode.field "grandparentTitle" Decode.string)
        (maybeZero <| Decode.field "viewOffset" Decode.int)


type alias Director =
    { id : Int
    , tag : String
    , filter : String
    }


type alias Writer =
    { id : Int
    , tag : String
    , filter : String
    }


type alias Genre =
    { id : Int
    , tag : String
    , filter : String
    }


type alias Guid =
    { id : String }


type alias Rating =
    { image : String
    , value : Float
    , typ : String
    }


type alias Role =
    { tag : String
    , filter : String
    , tagKey : String
    , role : String
    , thumb : String
    }


type alias Country =
    { tag : String, filter : String, id : Int }


type alias Media =
    { id : String --  Unique ID associated with the item.
    , duration : Int --    The length of the item in milliseconds.
    , bitrate : Int -- The bitrate of the item.
    , width : Float
    , height : Float
    , aspectRatio : Float
    , audioChannels : Int
    , audioCodec : String
    , videoCodec : String
    , videoResolution : String
    , optimizedForStreaming : Bool
    , container : String
    , videoFrameRate : String
    , videoProfile : String --    The video profile of the media.
    , audioProfile : String
    , has64bitOffsets : Bool
    , part : List MediaPart
    }


type alias MediaPart =
    { id : String --  Unique ID associated with the part.
    , key : String -- The unique relative path for the part that is used at its key.
    , duration : Int --    The length of the part in milliseconds.
    , file : String --    The file associated with the part.
    , size : Int --    The file size of the part.
    , audioProfile : String
    , container : String --   The type of media container.
    , has64bitOffsets : Bool
    , optimizedForStreaming : Bool
    , videoProfile : String --    The video profile associated with the video part.
    }


type alias Account =
    { id : Int --  An integer value representing the unique identifier for the account.
    , key : String -- The relative URL of the account used to get information about the account.
    , name : String --    The name of the account.
    , defaultAudioLanguage : String --    The default audio language used for the account.
    , autoSelectAudio : Bool -- 1 - automatically select the audio for the account. 0 - do not automatically select the audio for the account.
    , defaultSubtitleLanguage : String -- The default language for subtitles.
    , subtitleMode : Int --    An integer value representing the subtitle mode. The values are unknown.
    , thumb : String --   Thumbnail associated with the account.
    }


type alias Setting =
    { id : String --  The unique string value used to identify the preference.
    , label : String --   The label shown in the Plex Web app for the preference.
    , summary : String -- A descriptive summary of the preference.
    , typ : String --    The value type associated with the preference.
    , default : String -- The default value for the preference.
    , value : String --   The current value of the preference.
    , hidden : Bool --  Indicates if the preference is hidden.
    , advanced : Bool --    Indicates the preference is shown when the "Show Advanced" button is clicked in the Plex settings.
    , group : String --   The name of the Plex settings group where the preference can be found.
    , enumValues : List ( String, String ) --  The valid values for the preference in a key/value pair list.
    }


type alias Section =
    { title : String
    , size : Int
    , more : Bool
    , data : List (Tree Metadata)
    }


type Tree a
    = Branch a (List (Tree a))
    | Leaf a


type alias Client =
    { token : String
    , serverAddress : String
    }


clientGetJson : Decoder a -> String -> (Result Http.Error a -> msg) -> Client -> Cmd msg
clientGetJson decoder path tagger { serverAddress, token } =
    Http.request
        { url = serverAddress ++ path ++ "?X-Plex-Token=" ++ token
        , method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.emptyBody
        , expect = Http.expectJson tagger decoder
        , timeout = Nothing
        , tracker = Nothing
        }


libraryDecoder : Decoder Library
libraryDecoder =
    Decode.fail ""


getLibraries : String -> (Result Http.Error Library -> msg) -> Client -> Cmd msg
getLibraries =
    clientGetJson libraryDecoder


continueWatchingDecoder : Decoder Section
continueWatchingDecoder =
    Decode.at [ "MediaContainer", "Hub" ] <|
        Decode.index 0 <|
            Decode.map4
                (\title size more data ->
                    { title = title, size = size, more = more, data = List.map Leaf data }
                )
                (Decode.field "title" Decode.string)
                (Decode.field "size" Decode.int)
                (Decode.field "more" Decode.bool)
                (Decode.field "Metadata" <| Decode.list metadataDecoder)


getContinueWatching : (Result Http.Error Section -> msg) -> Client -> Cmd msg
getContinueWatching =
    clientGetJson continueWatchingDecoder "/hubs/continueWatching"


recentlyAddedDecoder : Decoder Section
recentlyAddedDecoder =
    Decode.fail ""


getRecentlyAdded : (Result Http.Error Section -> msg) -> Client -> Cmd msg
getRecentlyAdded =
    clientGetJson recentlyAddedDecoder "/recentlyAdded"


firstAccountWithName decoder =
    decoder
        |> Decode.list
        |> Decode.andThen
            (\accs ->
                case List.filter (\acc -> acc.name /= "") accs of
                    [] ->
                        Decode.fail "Account not found"

                    acc :: _ ->
                        Decode.succeed acc
            )
        |> Decode.at [ "MediaContainer", "Account" ]


accountDecoder : Decoder Account
accountDecoder =
    firstAccountWithName <|
        Decode.map8
            (\id key name defaultAudioLanguage autoSelectAudio defaultSubtitleLanguage subtitleMode thumb ->
                { id = id
                , key = key
                , name = name
                , defaultAudioLanguage = defaultAudioLanguage
                , autoSelectAudio = autoSelectAudio
                , defaultSubtitleLanguage = defaultSubtitleLanguage
                , subtitleMode = subtitleMode
                , thumb = thumb
                }
            )
            (Decode.field "id" Decode.int)
            (Decode.field "key" Decode.string)
            (Decode.field "name" Decode.string)
            (Decode.field "defaultAudioLanguage" Decode.string)
            (Decode.field "autoSelectAudio" Decode.bool)
            (Decode.field "defaultSubtitleLanguage" Decode.string)
            (Decode.field "subtitleMode" Decode.int)
            (Decode.field "thumb" Decode.string)


getAccount : (Result Http.Error Account -> msg) -> Client -> Cmd msg
getAccount =
    clientGetJson accountDecoder "/accounts"


getSettings : Client -> Task Http.Error (List Setting)
getSettings client =
    Task.fail Http.NetworkError