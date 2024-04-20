module Dto exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative.Dimensions exposing (ScaledSize, initialScaledSize)
import Utils exposing (maybeEmptyList, maybeEmptyString, maybeFalse, maybeFloatZero, maybeZero)


type alias Response data =
    Result Http.Error data



{-
   {
       "MediaContainer": {
           "size": 1,
           "allowCameraUpload": true,
           "allowChannelAccess": true,
           "allowMediaDeletion": true,
           "allowSharing": true,
           "allowSync": true,
           "allowTuners": true,
           "backgroundProcessing": true,
           "certificate": true,
           "companionProxy": true,
           "countryCode": "chn",
           "diagnostics": "logs,databases,streaminglogs",
           "eventStream": true,
           "friendlyName": "Dell",
           "livetv": 7,
           "machineIdentifier": "3c46f2b843eb0a7ba580469c245a81b9b4747bc6",
           "musicAnalysis": 2,
           "myPlex": true,
           "myPlexMappingState": "mapped",
           "myPlexSigninState": "ok",
           "myPlexSubscription": false,
           "myPlexUsername": "ichendesheng@gmail.com",
           "offlineTranscode": 1,
           "ownerFeatures": "044a1fac-6b55-47d0-9933-25a035709432,04d7d794-b76c-49ef-9184-52f8f1f501ee,06d14b9e-2af8-4c2b-a4a1-ea9d5c515824,07f804e6-28e6-4beb-b5c3-f2aefc88b938,0cce52a7-0778-4781-9a07-712370fb6b8a,0eee866d-782b-4dfd-b42b-3bbe8eb0af16,1417df52-986e-4e4b-8dcd-3997fbc5c976,1b870b8e-f1a7-497c-80b2-857d45f3123f,1f952ea5-0837-44cb-8539-a69a14a75d4a,228a6439-ee2f-4a9b-b0fc-1bfcd48b5095,22b27e12-472e-4383-92ea-2ec3976d8e72,24b4cf36-b296-4002-86b7-f1adb657e76a,2797e341-b062-46ed-862f-0acbba5dd522,298a11d3-9324-4104-8047-0ac10df4a8a6,2ea0e464-ea4f-4be2-97c1-ce6ed4b377dd,300231e0-69aa-4dce-97f4-52d8c00e3e8c,34e182bd-2f62-4678-a9e9-d13b3e25019d,39dbdd84-8339-4736-96a1-0eb105cc2e08,3ae06d3a-a76b-435e-8cef-2d2008610ba2,3c376154-d47e-4bbf-9428-2ea2592fd20a,3f6baa76-7488-479a-9e4f-49ff2c0d3711,4742780c-af9d-4b44-bf5b-7b27e3369aa8,4b522f91-ae89-4f62-af9c-76f44d8ef61c,4cd4dc0e-6cbe-456c-9988-9f073fadcd73,547514ab-3284-46e5-af77-bbaff247e3fc,567033ef-ffee-44fb-8f90-f678077445f9,5b6190a9-77a4-477e-9fbc-c8118e35a4c1,5d819d02-5d04-4116-8eec-f49def4e2d6f,5e2a89ec-fb26-4234-b66e-14d37f35dff2,62b1e357-5450-41d8-9b60-c7705f750849,644c4466-05fa-45e0-a478-c594cf81778f,64adaa4e-aa7e-457d-b385-51438216d7fe,65685ff8-4375-4e4c-a806-ec1f0b4a8b7f,67c80530-eae3-4500-a9fa-9b6947d0f6d1,68747f3a-ce13-46ce-9274-1e0544c9f500,6b85840c-d79d-40c2-8d8f-dfc0b7d26776,6c4d66d9-729d-49dc-b70d-ab2652abf15a,6d7be725-9a96-42c7-8af4-01e735138822,7b392594-6949-4736-9894-e57a9dfe4037,7f46bf17-fabf-4f96-99a2-cf374f6eed71,81c8d5fa-8d90-4833-aa10-a31a51310e2f,849433b0-ef60-4a71-9dd9-939bc01f5362,8536058d-e1dd-4ae7-b30f-e8b059b7cc17,85ebfb7b-77fb-4afd-bb1a-2fe2fefdddbe,86da2200-58db-4d78-ba46-f146ba25906b,88aba3a3-bd62-42a5-91bb-0558a4c1db57,8e8dd5c8-14a4-4208-97d4-623e09191774,96cac76e-c5bc-4596-87eb-4fdfef9aaa11,9a67bff2-cb80-4bf9-81c6-9ad2f4c78afd,9aea4ca5-2095-4619-9339-88c1e662fde6,9e93f8a8-7ccd-4d15-99fa-76a158027660,a19d495a-1cef-4f7c-ab77-5186e63e17f7,a3d2d5c4-46a0-436e-a2d6-80d26f32b369,a536a6e1-0ece-498a-bf64-99b53c27de3a,a548af72-b804-4d05-8569-52785952d31d,a6f3f9b3-c10c-4b94-ad59-755e30ac6c90,abd37b14-706c-461f-8255-fa9563882af3,adaptive_bitrate,b227c158-e062-4ff1-95d8-8ed11cecafb1,b2403ac6-4885-4971-8b96-59353fd87c72,b3b87f19-5ccd-4b14-bb62-b9d7b982392e,b46d16ae-cbd6-4226-8ee9-ab2b27e5dd42,b5874ecb-6610-47b2-8906-1b5a897acb02,b612f571-83c3-431a-88eb-3f05ce08da4a,b77e6744-c18d-415a-8e7c-7aac5d7a7750,bb50c92f-b412-44fe-8d8a-b1684f212a44,bec2ba97-4b25-472b-9cfc-674f5c68c2ae,c36a6985-eee3-4400-a394-c5787fad15b5,c55d5900-b546-416d-a8c5-45b24a13e9bc,c7ae6f8f-05e6-48bb-9024-c05c1dc3c43e,c987122a-a796-432f-af00-953821c127bb,c9d9b7ee-fdd9-474e-b143-5039c04e9b9b,camera_upload,cb151c05-1943-408a-b37c-06f7d409d6bb,cc9bea3b-11ab-4402-a222-4958bb129cab,ccef9d3a-537a-43d9-8161-4c7113c6e2bb,ce8f644e-87ce-4ba5-b165-fadd69778019,collections,d14556be-ae6d-4407-89d0-b83953f4789a,d1477307-4dac-4e57-9258-252e5b908693,d20f9af2-fdb1-4927-99eb-a2eb8fbff799,d29f0ee0-3d3a-46c3-b582-4bc69bc17c29,d85cb60c-0986-4a02-b1e1-36c64c609712,d9f42aea-bc9d-47db-9814-cd7a577aff48,dab501df-5d99-48ef-afc2-3e839e4ddc9a,db965785-ca5c-46fd-bab6-7b3d29c18492,de65add8-2782-4bb8-b156-e0b57a844479,download_certificates,e45bc5ae-1c3a-4729-922b-c69388c571b7,e4a9fd6f-4105-476b-bc57-adccd009323b,e66aa31c-abdd-483d-93bc-e17485d8837f,e703655b-ee05-4e24-97e3-a138da62c425,e7cea823-02e5-48c4-a501-d37b82bf132f,ea442c16-044a-4fa7-8461-62643f313c62,ee352392-2934-4061-ba35-5f3189f19ab4,f1ac7a53-c524-4311-9a27-713562fc24fa,f3235e61-c0eb-4718-ac0a-7d6eb3d8ff75,f3a99481-9671-4274-a0d3-4c06a72ef746,f83450e2-759a-4de4-8b31-e4a163896d43,f8463032-28f1-447b-a76c-8b57a071acad,f87f382b-4a41-4951-b4e4-d5822c69e4c6,f8ea4f37-c554-476a-8852-1cbd2912f3f6,fb34e64d-cd89-47b8-8bae-a6d20c542bae,fec722a0-a6d4-4fbd-96dc-4ffb02b072c5,federated-auth,home,kevin-bacon,livetv,loudness,radio,server-manager,shared-radio,tuner-sharing,type-first,unsupportedtuners",
           "platform": "Windows",
           "platformVersion": "10.0 (Build 22621)",
           "pluginHost": true,
           "pushNotifications": false,
           "readOnlyLibraries": false,
           "streamingBrainABRVersion": 3,
           "streamingBrainVersion": 2,
           "sync": true,
           "transcoderActiveVideoSessions": 0,
           "transcoderAudio": true,
           "transcoderLyrics": true,
           "transcoderSubtitles": true,
           "transcoderVideo": true,
           "transcoderVideoBitrates": "64,96,208,320,720,1500,2000,3000,4000,8000,10000,12000,20000",
           "transcoderVideoQualities": "0,1,2,3,4,5,6,7,8,9,10,11,12",
           "transcoderVideoResolutions": "128,128,160,240,320,480,768,720,720,1080,1080,1080,1080",
           "updatedAt": 1710681568,
           "updater": true,
           "version": "1.40.0.7998-c29d4c0c8",
           "voiceSearch": true,
           "MediaProvider": [
               {
                   "identifier": "com.plexapp.plugins.library",
                   "title": "Library",
                   "types": "video,audio,photo",
                   "protocols": "stream,download",
                   "Feature": [
                       {
                           "key": "/library/sections",
                           "type": "content",
                           "Directory": [
                               {
                                   "hubKey": "/hubs",
                                   "title": "Home"
                               },
                               {
                                   "agent": "tv.plex.agents.movie",
                                   "language": "en-US",
                                   "refreshing": false,
                                   "scanner": "Plex Movie",
                                   "uuid": "901162d8-4962-4fb3-ac73-6fdc720be33c",
                                   "id": "2",
                                   "key": "/library/sections/2",
                                   "hubKey": "/hubs/sections/2",
                                   "type": "movie",
                                   "title": "Movies",
                                   "updatedAt": 1682265906,
                                   "scannedAt": 1713140294,
                                   "Pivot": [
                                       {
                                           "id": "recommended",
                                           "key": "/hubs/sections/2",
                                           "type": "hub",
                                           "title": "Recommended",
                                           "context": "content.discover",
                                           "symbol": "star"
                                       },
                                       {
                                           "id": "library",
                                           "key": "/library/sections/2/all?type=1",
                                           "type": "list",
                                           "title": "Library",
                                           "context": "content.library",
                                           "symbol": "library"
                                       }
                                   ]
                               },
                               {
                                   "agent": "tv.plex.agents.series",
                                   "language": "en-US",
                                   "refreshing": false,
                                   "scanner": "Plex TV Series",
                                   "uuid": "11fc9729-b2dd-41e0-a4c4-5ec8e0c9f94a",
                                   "id": "1",
                                   "key": "/library/sections/1",
                                   "hubKey": "/hubs/sections/1",
                                   "type": "show",
                                   "title": "TV Shows",
                                   "updatedAt": 1682265877,
                                   "scannedAt": 1713605534,
                                   "Pivot": [
                                       {
                                           "id": "recommended",
                                           "key": "/hubs/sections/1",
                                           "type": "hub",
                                           "title": "Recommended",
                                           "context": "content.discover",
                                           "symbol": "star"
                                       },
                                       {
                                           "id": "library",
                                           "key": "/library/sections/1/all?type=2",
                                           "type": "list",
                                           "title": "Library",
                                           "context": "content.library",
                                           "symbol": "library"
                                       }
                                   ]
                               }
                           ]
                       },
                       {
                           "key": "/hubs/search",
                           "type": "search"
                       },
                       {
                           "key": "/library/matches",
                           "type": "match"
                       },
                       {
                           "key": "/library/metadata",
                           "type": "metadata"
                       },
                       {
                           "key": "/:/rate",
                           "type": "rate"
                       },
                       {
                           "key": "/photo/:/transcode",
                           "type": "imagetranscoder"
                       },
                       {
                           "key": "/hubs/promoted",
                           "type": "promoted"
                       },
                       {
                           "key": "/hubs/continueWatching",
                           "type": "continuewatching"
                       },
                       {
                           "key": "/actions",
                           "type": "actions",
                           "Action": [
                               {
                                   "id": "removeFromContinueWatching",
                                   "key": "/actions/removeFromContinueWatching"
                               }
                           ]
                       },
                       {
                           "flavor": "universal",
                           "key": "/playlists",
                           "type": "playlist"
                       },
                       {
                           "flavor": "universal",
                           "key": "/playQueues",
                           "type": "playqueue"
                       },
                       {
                           "key": "/library/collections",
                           "type": "collection"
                       },
                       {
                           "scrobbleKey": "/:/scrobble",
                           "unscrobbleKey": "/:/unscrobble",
                           "key": "/:/timeline",
                           "type": "timeline"
                       },
                       {
                           "type": "manage"
                       },
                       {
                           "type": "queryParser"
                       },
                       {
                           "flavor": "download",
                           "type": "subscribe"
                       }
                   ]
               }
           ]
       }
   }
-}


type alias MediaContainer =
    { platform : String
    , platformVersion : String
    , updatedAt : Int
    , updater : Bool
    }


providersResponseDecoder : Decoder MediaContainer
providersResponseDecoder =
    Decode.at [ "MediaContainer" ] mediaContainerDecoder


mediaContainerDecoder : Decoder MediaContainer
mediaContainerDecoder =
    Decode.map4 MediaContainer
        (Decode.field "platform" Decode.string)
        (Decode.field "platformVersion" Decode.string)
        (Decode.field "updatedAt" Decode.int)
        (Decode.field "updater" Decode.bool)


type alias Library =
    { allowSync : Bool -- 1 - allow the items in the to be synced. 0 - do not allow the items in the library to be synced.
    , art : String -- The background artwork used to represent the library.
    , composite : String -- The composite image associated with the library.
    , filters : Bool -- 1 - allow library filters. 0 - do no allow library filters.
    , scanning : Bool -- 1 - the library is refreshing the metadata. 0 - the library is not refreshing the metadata.
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


initialLibrary : Library
initialLibrary =
    { allowSync = False
    , art = ""
    , composite = ""
    , filters = False
    , scanning = False
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
                , scanning = refreshing
                , composite = composite
            }
        )
        (maybeEmptyString <| Decode.field "type" Decode.string)
        (maybeEmptyString <| Decode.field "key" Decode.string)
        (maybeEmptyString <| Decode.field "thumb" Decode.string)
        (maybeEmptyString <| Decode.field "title" Decode.string)
        (maybeEmptyString <| Decode.field "language" Decode.string)
        (maybeEmptyString <| Decode.field "uuid" Decode.string)
        (maybeFalse <| Decode.field "refreshing" Decode.bool)
        (maybeEmptyString <| Decode.field "composite" Decode.string)


type alias Location =
    { id : Int, path : String }


type alias Metadata =
    { ratingKey : String --   A key associated with the item.
    , key : String -- The relative URL of the item information.
    , guid : String --    The unique identifier comprised of the Plex agent and item identifier for the agent.
    , studio : String --  The name of the item studio.
    , typ : String --    The type of media.
    , title : String --   The title of the item.
    , contentRating : String --   The content rating associated with the item.
    , summary : String -- A summary of the item.
    , rating : Float --  The rating for the item.
    , audienceRating : Float --  The audience rating for the item.
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
    , medias : List Media
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
    , lastViewedAt : Maybe Int
    , viewCount : Maybe Int
    , viewOffset : Maybe Int
    }


initialMetadata : Metadata
initialMetadata =
    { ratingKey = ""
    , key = ""
    , guid = ""
    , studio = ""
    , typ = ""
    , title = ""
    , contentRating = ""
    , summary = ""
    , rating = 0
    , audienceRating = 0
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
    , medias = []
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
    , lastViewedAt = Nothing
    , viewCount = Nothing
    , viewOffset = Nothing
    }


metadataDecoder : Decoder Metadata
metadataDecoder =
    let
        decoder =
            Decode.map7
                (\summary guid typ thumb title duration grandparentTitle ->
                    { initialMetadata
                        | summary = summary
                        , guid = guid
                        , typ = typ
                        , thumb = thumb
                        , title = title
                        , duration = duration
                        , grandparentTitle = grandparentTitle
                    }
                )
                (Decode.field "summary" Decode.string)
                (Decode.field "guid" Decode.string)
                (Decode.field "type" Decode.string)
                (maybeEmptyString <| Decode.field "thumb" Decode.string)
                (maybeEmptyString <| Decode.field "title" Decode.string)
                (maybeZero <| Decode.field "duration" Decode.int)
                (maybeEmptyString <| Decode.field "grandparentTitle" Decode.string)

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
                (maybeEmptyString <| Decode.field "grandparentTitle" Decode.string)
                (maybeEmptyString <| Decode.field "grandparentThumb" Decode.string)
                (maybeEmptyString <| Decode.field "parentTitle" Decode.string)
                (maybeEmptyString <| Decode.field "parentThumb" Decode.string)
                (maybeEmptyString <| Decode.field "tagline" Decode.string)
                (maybeEmptyString <| Decode.field "contentRating" Decode.string)
                (maybeEmptyString <| Decode.field "originallyAvailableAt" Decode.string)

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
                (maybeEmptyString <| Decode.field "ratingKey" Decode.string)
                (maybeEmptyString <| Decode.field "parentRatingKey" Decode.string)
                (maybeEmptyString <| Decode.field "grandparentRatingKey" Decode.string)

        decoder5 =
            Decode.map8
                (\data viewOffset lastViewedAt viewCount rating ratingImage audienceRating audienceRatingImage ->
                    { data
                        | viewOffset = viewOffset
                        , lastViewedAt = lastViewedAt
                        , viewCount = viewCount
                        , rating = rating
                        , ratingImage = ratingImage
                        , audienceRating = audienceRating
                        , audienceRatingImage = audienceRatingImage
                    }
                )
                decoder4
                (Decode.maybe <| Decode.field "viewOffset" Decode.int)
                (Decode.maybe <| Decode.field "lastViewedAt" Decode.int)
                (Decode.maybe <| Decode.field "viewCount" Decode.int)
                (maybeFloatZero <| Decode.field "rating" Decode.float)
                (maybeEmptyString <| Decode.field "ratingImage" Decode.string)
                (maybeFloatZero <| Decode.field "audienceRating" Decode.float)
                (maybeEmptyString <| Decode.field "audienceRatingImage" Decode.string)

        decoder6 =
            Decode.map5
                (\data directors roles writers medias ->
                    { data
                        | directors = directors
                        , roles = roles
                        , writers = writers
                        , medias = medias
                    }
                )
                decoder5
                (maybeEmptyList <| Decode.field "Director" <| Decode.list directorDecoder)
                (maybeEmptyList <| Decode.field "Role" <| Decode.list roleDecoder)
                (maybeEmptyList <| Decode.field "Writer" <| Decode.list writerDecoder)
                (maybeEmptyList <| Decode.field "Media" <| Decode.list mediaDecoder)
    in
    decoder6


type alias Director =
    { id : Int
    , tag : String
    , filter : String
    }


directorDecoder : Decoder Director
directorDecoder =
    Decode.map3 Director
        (maybeZero <| Decode.field "id" Decode.int)
        (Decode.field "tag" Decode.string)
        (maybeEmptyString <| Decode.field "filter" Decode.string)


type alias Writer =
    Director


writerDecoder =
    directorDecoder


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


roleDecoder : Decoder Role
roleDecoder =
    Decode.map5 Role
        (Decode.field "tag" Decode.string)
        (maybeEmptyString <| Decode.field "filter" Decode.string)
        (maybeEmptyString <| Decode.field "tagKey" Decode.string)
        (maybeEmptyString <| Decode.field "role" Decode.string)
        (maybeEmptyString <| Decode.field "thumb" Decode.string)


type alias Country =
    { tag : String, filter : String, id : Int }


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


settingsDecoder : Decoder (List Setting)
settingsDecoder =
    Decode.fail "todo"


type alias Section =
    { title : String
    , more : Bool
    , data : List Metadata
    , hubIdentifier : String
    }


type alias Resource =
    { name : String
    , provides : String
    , accessToken : String
    , connections : List Connection
    }


type alias Connection =
    { local : Bool, uri : String }


resourceDecoder : Decoder Resource
resourceDecoder =
    Decode.map4 Resource
        (Decode.field "name" Decode.string)
        (Decode.field "provides" Decode.string)
        (maybeEmptyString <| Decode.field "accessToken" Decode.string)
        (Decode.field "connections" <| Decode.list connectionDecoder)


connectionDecoder : Decode.Decoder Connection
connectionDecoder =
    Decode.map2 Connection
        (Decode.field "local" Decode.bool)
        (Decode.field "uri" Decode.string)


type alias SignInResponse =
    { username : String
    , thumb : String
    , authToken : String
    }


siginResponseDecoder : Decoder SignInResponse
siginResponseDecoder =
    Decode.map3 SignInResponse
        (Decode.field "username" Decode.string)
        (Decode.field "thumb" Decode.string)
        (Decode.field "authToken" Decode.string)


type alias TimelineRequest =
    { ratingKey : String
    , time : Int
    , duration : Int
    , state : String
    }


type alias TimelineResponse =
    { playbackState : String, viewOffset : Int, skipCount : Int, viewCount : Int }


timelineResponseDecoder : Decoder TimelineResponse
timelineResponseDecoder =
    Decode.map4 TimelineResponse
        (Decode.field "playbackState" <| Decode.string)
        (Decode.field "viewOffset" <| Decode.int)
        (Decode.field "skipCount" <| Decode.int)
        (Decode.field "viewCount" <| Decode.int)


firstAccountWithName : Decoder Account -> Decoder Account
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


sectionDecoder : Decoder Section
sectionDecoder =
    Decode.map4
        (\hubIdentifier title more data ->
            { hubIdentifier = hubIdentifier, title = title, more = more, data = data }
        )
        (Decode.field "hubIdentifier" Decode.string)
        (Decode.field "title" Decode.string)
        (maybeFalse <| Decode.field "more" Decode.bool)
        (maybeEmptyList <| Decode.field "Metadata" <| Decode.list metadataDecoder)


sectionsDecoder : Decoder (List Section)
sectionsDecoder =
    Decode.at [ "MediaContainer", "Hub" ] <| Decode.list sectionDecoder


firstSectionDecoder : Decoder Section
firstSectionDecoder =
    Decode.at [ "MediaContainer", "Hub" ] <|
        Decode.index 0 sectionDecoder


metadataListDecoder : Decoder (List Metadata)
metadataListDecoder =
    Decode.field "MediaContainer" <|
        maybeEmptyList <|
            Decode.field "Metadata" <|
                Decode.list metadataDecoder


type alias Media =
    { id : Int --  Unique ID associated with the item.
    , duration : Int --    The length of the item in milliseconds.
    , parts : List MediaPart
    }


type alias MediaPart =
    { id : Int --  Unique ID associated with the part.
    , streams : List MediaStream
    , file : String
    , size : Int
    }


type alias MediaStream =
    { id : Int -- 4230,
    , key : String
    , streamType : Int -- 1 video, 2 audio, 3 subtitle,
    , default : Bool -- true,
    , codec : String -- "h264",
    , index : Int -- 0,
    , displayTitle : String -- "1080p (H.264)",
    , extendedDisplayTitle : String -- "1080p (H.264)"
    , format : String -- srt
    , sourceKey : String
    , selected : Bool
    , language : String
    , width : Int
    , height : Int
    }


mediaDecoder : Decode.Decoder Media
mediaDecoder =
    Decode.succeed
        (\id duration parts ->
            { id = id
            , duration = duration
            , parts = parts
            }
        )
        |> decodeAndMap (Decode.field "id" Decode.int)
        |> decodeAndMap (Decode.field "duration" Decode.int)
        |> decodeAndMap (Utils.maybeEmptyList <| Decode.field "Part" (Decode.list decodeMediaPart))


decodeMediaPart : Decode.Decoder MediaPart
decodeMediaPart =
    Decode.succeed
        (\id streams file size ->
            { id = id
            , streams = streams
            , file = file
            , size = size
            }
        )
        |> decodeAndMap (Decode.field "id" Decode.int)
        |> decodeAndMap (Utils.maybeEmptyList <| Decode.field "Stream" (Decode.list streamDecoder))
        |> decodeAndMap (Decode.field "file" Decode.string)
        |> decodeAndMap (Decode.field "size" Decode.int)


streamDecoder : Decode.Decoder MediaStream
streamDecoder =
    Decode.succeed
        (\id key streamType default codec index displayTitle extendedDisplayTitle format sourceKey selected language width height ->
            { id = id
            , key = key
            , streamType = streamType
            , default = default
            , codec = codec
            , index = index
            , format = format
            , displayTitle = displayTitle
            , extendedDisplayTitle = extendedDisplayTitle
            , sourceKey = sourceKey
            , selected = selected
            , language = language
            , width = width
            , height = height
            }
        )
        |> decodeAndMap (Decode.field "id" Decode.int)
        |> decodeAndMap (Utils.maybeEmptyString <| Decode.field "key" Decode.string)
        |> decodeAndMap (Decode.field "streamType" Decode.int)
        |> decodeAndMap (Utils.maybeFalse <| Decode.field "default" Decode.bool)
        |> decodeAndMap (Decode.field "codec" Decode.string)
        |> decodeAndMap (Utils.maybeZero <| Decode.field "index" Decode.int)
        |> decodeAndMap (Decode.field "displayTitle" Decode.string)
        |> decodeAndMap (Decode.field "extendedDisplayTitle" Decode.string)
        |> decodeAndMap (Utils.maybeEmptyString <| Decode.field "format" Decode.string)
        |> decodeAndMap (Utils.maybeEmptyString <| Decode.field "sourceKey" Decode.string)
        |> decodeAndMap (Utils.maybeFalse <| Decode.field "selected" Decode.bool)
        |> decodeAndMap (Utils.maybeEmptyString <| Decode.field "language" Decode.string)
        |> decodeAndMap (Utils.maybeZero <| Decode.field "width" Decode.int)
        |> decodeAndMap (Utils.maybeZero <| Decode.field "height" Decode.int)


decodeAndMap : Decode.Decoder a -> Decode.Decoder (a -> b) -> Decode.Decoder b
decodeAndMap =
    Decode.map2 (|>)


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
