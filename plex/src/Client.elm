module Client exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative.Dimensions exposing (DisplayMetrics, getScreen, initialDisplayMetrics)
import ReactNative.Settings as Settings
import Task exposing (Task)
import Utils


type alias Client =
    { token : String
    , serverAddress : String
    , serverName : String
    , id : String
    , email : String
    , password : String
    , screenMetrics : DisplayMetrics
    }


initialClient : Client
initialClient =
    { id = ""
    , serverAddress = "https://plex.tv/api/v2"
    , serverName = ""
    , token = ""
    , email = ""
    , password = ""
    , screenMetrics = initialDisplayMetrics
    }


toDecodeError : Task Never x -> Task Decode.Error x
toDecodeError =
    Task.mapError (always <| Decode.Failure "" Encode.null)


loadClient : (Result Decode.Error Client -> msg) -> Cmd msg
loadClient tagger =
    getScreen
        |> toDecodeError
        |> Task.andThen
            (\screenMetrics ->
                Task.map5
                    (\id token serverAddress serverName email ->
                        { token = token
                        , serverAddress = serverAddress
                        , serverName = serverName
                        , id = id
                        , email = email
                        , password = ""
                        , screenMetrics = screenMetrics
                        }
                    )
                    (Settings.get "clientId" <| Utils.maybeEmptyString Decode.string)
                    (Settings.get "token" Decode.string)
                    (Settings.get "serverAddress" Decode.string)
                    (Settings.get "serverName" Decode.string)
                    (Settings.get "email" <| Utils.maybeEmptyString Decode.string)
            )
        |> Task.attempt tagger


saveClient : msg -> Client -> Cmd msg
saveClient msg client =
    let
        encode s =
            if String.isEmpty s then
                Encode.null

            else
                Encode.string s
    in
    Task.perform (always msg) <|
        Settings.set
            [ ( "serverAddress", encode client.serverAddress )
            , ( "serverName", encode client.serverName )
            , ( "token", encode client.token )
            , ( "clientId", encode client.id )
            , ( "email", encode client.email )
            ]
