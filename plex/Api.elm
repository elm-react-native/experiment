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


initialLibrary =
    { allowSync = False
    , art = ""
    , composite = ""
    , filters = False
    , refreshing = False
    , thumb = ""
    , key = ""
    , typ = ""
    , title = ""
    , agent = ""
    , scanner = ""
    , language = ""
    , uuid = ""
    , updatedAt = 0
    , createdAt = 0
    , scannedAt = 0
    , content = False
    , directory = False
    , contentChangedAt = 0
    , hidden = False
    , location = []
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
    , originallyAvailableAt : String --   The original release date of the item.
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
    , originallyAvailableAt = ""
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


maybeFalse =
    maybeWithDefault False


maybeEmpty =
    maybeWithDefault []


metadataDecoder : Decoder Metadata
metadataDecoder =
    let
        decoder =
            Decode.map8
                (\summary guid typ thumb title duration grandparentTitle viewOffset ->
                    { initialMetadata
                        | summary = summary
                        , guid = guid
                        , typ = typ
                        , thumb = thumb
                        , title = title
                        , duration = duration
                        , grandparentTitle = grandparentTitle
                        , viewOffset = viewOffset
                    }
                )
                (Decode.field "summary" Decode.string)
                (Decode.field "guid" Decode.string)
                (Decode.field "type" Decode.string)
                (Decode.field "thumb" Decode.string)
                (maybeString <| Decode.field "title" Decode.string)
                (maybeZero <| Decode.field "duration" Decode.int)
                (maybeString <| Decode.field "grandparentTitle" Decode.string)
                (maybeZero <| Decode.field "viewOffset" Decode.int)

        decoder2 =
            Decode.map8
                (\data grandparentTitle grandparentThumb parentTitle parentThumb tagline contentRating originallyAvailableAt ->
                    { data
                        | grandparentTitle = grandparentTitle
                        , grandparentThumb = grandparentThumb
                        , parentTitle = parentTitle
                        , parentThumb = parentThumb
                        , tagline = tagline
                        , contentRating = contentRating
                        , originallyAvailableAt = originallyAvailableAt
                    }
                )
                decoder
                (maybeString <| Decode.field "grandparentTitle" Decode.string)
                (maybeString <| Decode.field "grandparentThumb" Decode.string)
                (maybeString <| Decode.field "parentTitle" Decode.string)
                (maybeString <| Decode.field "parentThumb" Decode.string)
                (maybeString <| Decode.field "tagline" Decode.string)
                (maybeString <| Decode.field "contentRating" Decode.string)
                (maybeString <| Decode.field "originallyAvailableAt" Decode.string)

        decoder3 =
            Decode.map4
                (\data index parentIndex grandparentIndex ->
                    { data
                        | index = index
                        , parentIndex = parentIndex
                        , grandparentIndex = grandparentIndex
                    }
                )
                decoder2
                (maybeZero <| Decode.field "index" Decode.int)
                (maybeZero <| Decode.field "parentIndex" Decode.int)
                (maybeZero <| Decode.field "grandparentIndex" Decode.int)

        decoder4 =
            Decode.map4
                (\data ratingKey parentRatingKey grandparentRatingKey ->
                    { data
                        | ratingKey = ratingKey
                        , parentRatingKey = parentRatingKey
                        , grandparentRatingKey = grandparentRatingKey
                    }
                )
                decoder3
                (maybeString <| Decode.field "ratingKey" Decode.string)
                (maybeString <| Decode.field "parentRatingKey" Decode.string)
                (maybeString <| Decode.field "grandparentRatingKey" Decode.string)
    in
    decoder4


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
    , more : Bool
    , data : List Metadata
    , hubIdentifier : String
    }


type alias Client =
    { token : String
    , serverAddress : String
    }


httpJsonBodyResolver : Decoder a -> Http.Response String -> Result Http.Error a
httpJsonBodyResolver decoder resp =
    let
        res =
            case resp of
                Http.GoodStatus_ m s ->
                    Decode.decodeString decoder s
                        |> Result.mapError (Decode.errorToString >> Http.BadBody)

                Http.BadUrl_ s ->
                    Err (Http.BadUrl s)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ m s ->
                    Decode.decodeString decoder s
                        -- just trying; if our decoder understands the response body, great
                        |> Result.mapError (\_ -> Http.BadStatus m.statusCode)

        _ =
            Debug.log "response" resp
    in
    res


clientGetJsonTask : Decoder a -> String -> Client -> Task Http.Error a
clientGetJsonTask decoder path { serverAddress, token } =
    let
        url =
            serverAddress
                ++ path
                ++ (if String.contains path "?" then
                        "&"

                    else
                        "?"
                   )
                ++ "X-Plex-Token="
                ++ token

        _ =
            Debug.log "url" url
    in
    Http.task
        { url = url
        , method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| httpJsonBodyResolver decoder
        , timeout = Nothing
        }


clientGetJson : Decoder a -> String -> (Result Http.Error a -> msg) -> Client -> Cmd msg
clientGetJson decoder path tagger { serverAddress, token } =
    let
        url =
            serverAddress
                ++ path
                ++ (if String.contains "?" path then
                        "&"

                    else
                        "?"
                   )
                ++ "X-Plex-Token="
                ++ token

        _ =
            Debug.log "url" url
    in
    Http.request
        { url = url
        , method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , body = Http.emptyBody
        , expect = Http.expectJson tagger decoder
        , timeout = Nothing
        , tracker = Nothing
        }


librariesDecoder : Decoder (List Library)
librariesDecoder =
    Decode.at [ "MediaContainer", "Directory" ] <| Decode.list libraryDecoder


libraryDecoder : Decoder Library
libraryDecoder =
    Decode.map8
        (\typ key thumb title language uuid refreshing composite ->
            { initialLibrary
                | typ = typ
                , key = key
                , thumb = thumb
                , title = title
                , language = language
                , uuid = uuid
                , refreshing = refreshing
                , composite = composite
            }
        )
        (maybeString <| Decode.field "type" Decode.string)
        (maybeString <| Decode.field "key" Decode.string)
        (maybeString <| Decode.field "thumb" Decode.string)
        (maybeString <| Decode.field "title" Decode.string)
        (maybeString <| Decode.field "language" Decode.string)
        (maybeString <| Decode.field "uuid" Decode.string)
        (maybeFalse <| Decode.field "refreshing" Decode.bool)
        (maybeString <| Decode.field "composite" Decode.string)


getLibraries : String -> (Result Http.Error (List Library) -> msg) -> Client -> Cmd msg
getLibraries =
    clientGetJson librariesDecoder


sectionsDecoder : Decoder (List Section)
sectionsDecoder =
    Decode.at [ "MediaContainer", "Hub" ] <|
        Decode.list <|
            Decode.map4
                (\hubIdentifier title more data ->
                    { hubIdentifier = hubIdentifier, title = title, more = more, data = data }
                )
                (Decode.field "hubIdentifier" Decode.string)
                (Decode.field "title" Decode.string)
                (maybeFalse <| Decode.field "more" Decode.bool)
                (maybeEmpty <| Decode.field "Metadata" <| Decode.list metadataDecoder)


metadataListDecoder : Decoder (List Metadata)
metadataListDecoder =
    Decode.field "MediaContainer" <|
        maybeEmpty <|
            Decode.field "Metadata" <|
                Decode.list metadataDecoder


getSections : (Result Http.Error (List Section) -> msg) -> Client -> Cmd msg
getSections =
    clientGetJson sectionsDecoder "/hubs?size=12"


getMetadata : String -> Client -> Task Http.Error Metadata
getMetadata key =
    clientGetJsonTask (Decode.at [ "MediaContainer", "Metadata" ] <| Decode.index 0 <| metadataDecoder) ("/library/metadata/" ++ key)


getMetadataChildren : String -> Client -> Task Http.Error (List Metadata)
getMetadataChildren key =
    clientGetJsonTask metadataListDecoder <| "/library/metadata/" ++ key ++ "/children"


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
