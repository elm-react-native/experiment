module Plex exposing (..)

import Api exposing (Account, Client, Metadata, Section)
import Browser
import Browser.Navigation as N
import Dict exposing (Dict, member)
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative
    exposing
        ( activityIndicator
        , button
        , image
        , imageBackground
        , ionicon
        , keyboardAvoidingView
        , null
        , require
        , scrollView
        , str
        , text
        , textInput
        , touchableOpacity
        , touchableWithoutFeedback
        , view
        )
import ReactNative.ActionSheetIOS as ActionSheetIOS
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onChangeText, onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Properties
    exposing
        ( behavior
        , color
        , component
        , componentModel
        , contentContainerStyle
        , disabled
        , getId
        , horizontal
        , imageStyle
        , name
        , options
        , persistentScrollbar
        , placeholder
        , placeholderTextColor
        , secureTextEntry
        , showsHorizontalScrollIndicator
        , size
        , source
        , stringValue
        , style
        , title
        )
import ReactNative.Settings as Settings
import ReactNative.StatusBar as StatusBar
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


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


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( Initial key
    , Task.map2 (\token serverAddress -> { token = token, serverAddress = serverAddress })
        (Settings.get "token" Decode.string)
        (Settings.get "serverAddress" Decode.string)
        |> Task.attempt (Result.map SignInSubmit >> Result.withDefault GotoSignIn)
    )



-- UPDATE


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


initialClient : { serverAddress : String, token : String }
initialClient =
    { serverAddress = "", token = "" }


signInSubmit : Client -> Cmd Msg
signInSubmit =
    Api.getAccount SignInSubmitResponse


getSections : Client -> Cmd Msg
getSections =
    Api.getSections GotSections


getTVShow : String -> String -> Client -> Cmd Msg
getTVShow id seasonId client =
    Api.getMetadata id client
        |> Task.andThen
            (\show ->
                Api.getMetadataChildren id client
                    |> Task.map (\seasons -> { info = show, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
            )
        |> Task.attempt (GotTVShow id)


getSeasons : Metadata -> String -> Client -> Cmd Msg
getSeasons tvShowInfo seasonId client =
    Api.getMetadataChildren tvShowInfo.ratingKey client
        |> Task.map (\seasons -> { info = tvShowInfo, seasons = List.map (\s -> { info = s, episodes = Nothing }) seasons, selectedSeason = seasonId })
        |> Task.attempt (GotTVShow tvShowInfo.ratingKey)


getEpisodes : String -> String -> Client -> Cmd Msg
getEpisodes showId seasonId client =
    Api.getMetadataChildren seasonId client
        |> Task.attempt (GotEpisodes showId seasonId)


saveClient : Client -> Cmd Msg
saveClient client =
    Task.perform (always NoOp) <|
        Settings.set
            [ ( "serverAddress", Encode.string client.serverAddress )
            , ( "token", Encode.string client.token )
            ]


pathToAuthedUrl : String -> Client -> String
pathToAuthedUrl path client =
    client.serverAddress ++ path ++ "?X-Plex-Token=" ++ client.token


updateEpisodes : String -> Result Http.Error (List Metadata) -> List TVSeason -> List TVSeason
updateEpisodes seasonId resp seasons =
    List.map
        (\season ->
            if season.info.ratingKey == seasonId then
                { season | episodes = Just resp }

            else
                season
        )
        seasons


updateTVShow : (TVShow -> TVShow) -> String -> Dict String (Result Http.Error TVShow) -> Dict String (Result Http.Error TVShow)
updateTVShow fn showId tvShows =
    case Dict.get showId tvShows of
        Just (Ok show) ->
            Dict.insert showId (Ok <| fn show) tvShows

        _ ->
            tvShows


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotoSignIn ->
            case model of
                Initial key ->
                    ( SignIn { client = initialClient, navKey = key, submitting = False }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInInputToken token ->
            case model of
                SignIn m ->
                    let
                        client =
                            m.client
                    in
                    ( SignIn { m | client = { client | token = token } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInInputAddress serverAddress ->
            case model of
                SignIn m ->
                    let
                        client =
                            m.client
                    in
                    ( SignIn { m | client = { client | serverAddress = serverAddress } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignInSubmit client ->
            case model of
                Initial key ->
                    ( SignIn { client = client, navKey = key, submitting = True }, signInSubmit client )

                SignIn m ->
                    ( SignIn { m | client = client, submitting = True }, signInSubmit client )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Ok account) ->
            case model of
                SignIn { client, navKey } ->
                    ( Home
                        { sections = Nothing
                        , account =
                            if String.isEmpty account.thumb then
                                account

                            else
                                { account | thumb = pathToAuthedUrl account.thumb client }
                        , client = client
                        , tvShows = Dict.empty
                        , navKey = navKey
                        }
                    , Cmd.batch [ saveClient client, getSections client ]
                    )

                _ ->
                    ( model, Cmd.none )

        SignInSubmitResponse (Err err) ->
            case model of
                SignIn m ->
                    let
                        errMessage =
                            case err of
                                Http.BadUrl _ ->
                                    "Server address is invalid."

                                Http.BadStatus 401 ->
                                    "Token is invalid or expired."

                                _ ->
                                    "Network error."
                    in
                    ( SignIn { m | submitting = False }, Task.perform (always NoOp) <| Alert.alert errMessage [] )

                _ ->
                    ( model, Cmd.none )

        ReloadSections ->
            case model of
                Home m ->
                    ( Home { m | sections = Nothing }, getSections m.client )

                _ ->
                    ( model, Cmd.none )

        GotSections resp ->
            ( case model of
                Home m ->
                    Home { m | sections = Just resp }

                _ ->
                    model
            , Cmd.none
            )

        GotTVShow showId resp ->
            case model of
                Home m ->
                    case resp of
                        Ok respShow ->
                            ( Home { m | tvShows = Dict.insert showId resp m.tvShows }
                            , case findSeason respShow.selectedSeason respShow of
                                Just season ->
                                    case season.episodes of
                                        Just (Ok _) ->
                                            Cmd.none

                                        _ ->
                                            getEpisodes showId respShow.selectedSeason m.client

                                _ ->
                                    Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotEpisodes showId seasonId resp ->
            case model of
                Home m ->
                    case Dict.get showId m.tvShows of
                        Just (Ok show) ->
                            let
                                seasons =
                                    updateEpisodes seasonId resp show.seasons
                            in
                            ( Home { m | tvShows = Dict.insert showId (Ok { show | seasons = seasons }) m.tvShows }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ShowSection _ ->
            ( model, Cmd.none )

        ShowEntity _ _ ->
            ( model, Cmd.none )

        GotoAccount ->
            case model of
                Home m ->
                    ( model, Nav.push m.navKey "account" {} )

                _ ->
                    ( model, Cmd.none )

        GotoEntity isContinueWatching metadata ->
            case model of
                Home m ->
                    let
                        getEpisodesIfNotFetched : String -> TVShow -> Cmd Msg
                        getEpisodesIfNotFetched seasonId show =
                            let
                                targetSeason =
                                    findSeason seasonId show
                            in
                            case targetSeason of
                                Just { episodes } ->
                                    case episodes of
                                        Just (Ok _) ->
                                            Cmd.none

                                        _ ->
                                            getEpisodes metadata.grandparentKey metadata.parentKey m.client

                                _ ->
                                    Cmd.none
                    in
                    ( model
                    , Cmd.batch
                        [ Nav.push m.navKey "entity" { isContinueWatching = isContinueWatching, metadata = metadata }
                        , if metadata.typ == "episode" then
                            case Dict.get metadata.grandparentRatingKey m.tvShows of
                                Just (Ok show) ->
                                    getEpisodesIfNotFetched metadata.parentRatingKey show

                                _ ->
                                    getTVShow metadata.grandparentRatingKey metadata.parentRatingKey m.client

                          else if metadata.typ == "season" then
                            case Dict.get metadata.parentRatingKey m.tvShows of
                                Just (Ok show) ->
                                    getEpisodesIfNotFetched metadata.parentRatingKey show

                                _ ->
                                    getTVShow metadata.parentRatingKey metadata.ratingKey m.client

                          else if metadata.typ == "show" then
                            case Dict.get metadata.ratingKey m.tvShows of
                                Just (Ok show) ->
                                    getEpisodesIfNotFetched "" show

                                _ ->
                                    getSeasons metadata "" m.client

                          else
                            Cmd.none
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        ChangeSeason showId seasonId ->
            case model of
                Home m ->
                    ( Home { m | tvShows = updateTVShow (\sh -> { sh | selectedSeason = seasonId }) showId m.tvShows }
                    , getEpisodes showId seasonId m.client
                    )

                _ ->
                    ( model, Cmd.none )

        SignOut ->
            case model of
                Home m ->
                    ( SignIn { client = m.client, navKey = m.navKey, submitting = False }
                    , saveClient { serverAddress = "", token = "" }
                    )

                _ ->
                    ( model, Cmd.none )

        DismissKeyboard ->
            ( model, Task.perform (always NoOp) Keyboard.dismiss )

        ShowPicker items ->
            ( model
            , ActionSheetIOS.pickAction (( "Cancel", NoOp ) :: items)
                [ ActionSheetIOS.cancelButtonIndex 0
                , ActionSheetIOS.tintColor themeColor
                ]
                |> Task.perform (Maybe.withDefault NoOp)
            )



-- VIEW


themeColor : String
themeColor =
    "#EBAF00"


backgroundColor : String
backgroundColor =
    "#2c2c2c"


signInStyles =
    StyleSheet.create
        { container =
            { justifyContent = "center"
            , alignItems = "center"
            , display = "flex"
            , height = "100%"
            , width = "100%"
            , backgroundColor = "#2c2c2c"
            }
        , form =
            { width = "80%" }
        , logo =
            { height = 59
            , width = 128
            , alignSelf = "center"
            , marginBottom = 30
            }
        , input =
            { borderBottomWidth = StyleSheet.hairlineWidth
            , height = 44
            , marginBottom = 20
            , color = "white"
            , borderColor = themeColor
            }
        , button =
            { backgroundColor = themeColor
            , height = 44
            , borderRadius = 3
            , justifyContent = "center"
            , alignItems = "center"
            }
        , buttonDisabled =
            { opacity = 0.5 }
        , buttonText =
            { color = "white", fontSize = 16, fontWeight = "bold" }
        }


signInScreen : SignInModel -> Html Msg
signInScreen { client, submitting } =
    touchableWithoutFeedback
        [ onPress <| Decode.succeed DismissKeyboard
        ]
        [ view
            [ style signInStyles.container
            ]
            [ keyboardAvoidingView
                [ style signInStyles.form
                , behavior "height"
                ]
                [ image
                    [ source <| require "./assets/plex-logo.png"
                    , style signInStyles.logo
                    ]
                    []
                , textInput
                    [ style signInStyles.input
                    , disabled submitting
                    , placeholder "Address http://192.168.1.1:32400"
                    , placeholderTextColor "#555"
                    , stringValue client.serverAddress
                    , onChangeText SignInInputAddress
                    ]
                    []
                , textInput
                    [ style signInStyles.input
                    , disabled submitting
                    , placeholder "Token hoSG7jeEsYDMQnstqnzP"
                    , placeholderTextColor "#555"
                    , stringValue client.token
                    , secureTextEntry True
                    , onChangeText SignInInputToken
                    ]
                    []
                , let
                    buttonDisabled =
                        submitting
                            || String.isEmpty client.serverAddress
                            || String.isEmpty client.token
                  in
                  touchableOpacity
                    [ if buttonDisabled then
                        style <| StyleSheet.compose signInStyles.button signInStyles.buttonDisabled

                      else
                        style signInStyles.button
                    , disabled buttonDisabled
                    , onPress <| Decode.succeed <| SignInSubmit client
                    ]
                    [ if submitting then
                        activityIndicator [ color "white" ] []

                      else
                        text
                            [ style signInStyles.buttonText ]
                            [ str "Sign In" ]
                    ]
                ]
            ]
        ]


homeStyles =
    StyleSheet.create
        { loading =
            { alignItems = "center"
            , justifyContent = "center"
            , height = "100%"
            , width = "100%"
            , backgroundColor = backgroundColor
            }
        , loadErrorText = { fontSize = 15, color = "white" }
        , container = { height = "100%", backgroundColor = backgroundColor }
        , sectionContainer =
            { height = 180, paddingVertical = 5 }
        , sectionTitle =
            { fontSize = 15
            , fontWeight = "bold"
            , color = "white"
            , marginLeft = 5
            , marginBottom = 4
            }
        , sectionContent =
            { flexDirection = "row"
            , alignItems = "center"
            , justifyContent = "center"
            }
        , sectionContentLoading =
            { width = "100%" }
        , itemContainer =
            { marginHorizontal = 5
            , overflow = "hidden"
            , width = 100
            , height = 148
            }
        , itemContainerBottomRadius =
            { height = 148
            }
        , itemImage =
            { justifyContent = "flex-end"
            , width = 100
            , height = 142
            }
        , itemImageAlt =
            { position = "absolute"
            , top = 0
            , left = 0
            , right = 0
            , bottom = 0
            , justifyContent = "center"
            , alignItems = "center"
            }
        , itemImageAltText =
            { fontSize = 12
            , color = "white"
            , fontWeight = "bold"
            }
        , itemLabel =
            { fontSize = 10
            , lineHeight = 10
            , fontWeight = "bold"
            , color = "white"
            }
        , itemLabelBackground =
            { alignItems = "center"
            , justifyContent = "flex-end"
            , height = 15
            , overflow = "hidden"
            }
        , progress =
            { backgroundColor = themeColor
            , height = 3
            }
        }


percentFloat : Float -> String
percentFloat f =
    (String.fromInt <| ceiling <| f * 100) ++ "%"


itemLabel : String -> Html msg
itemLabel label =
    imageBackground
        [ style homeStyles.itemLabelBackground
        , source <| require "./assets/gradient.png"
        , imageStyle { resizeMode = "repeat" }
        ]
        [ text [ style homeStyles.itemLabel ]
            [ str label ]
        ]


videoPlay : Decoder msg -> Html msg
videoPlay handlePress =
    view
        [ style
            { backgroundColor = "rgba(0,0,0,0.6)"
            , borderRadius = 15
            , borderColor = "white"
            , borderWidth = 1
            }
        ]
        [ touchableOpacity
            [ onPress handlePress
            , style
                { width = 28
                , height = 28
                , justifyContent = "center"
                , alignItems = "center"
                , left = 1
                }
            ]
            [ ionicon "play" [ color "white", size 15 ] ]
        ]


vidoePlayContainer : Decoder msg -> Html msg
vidoePlayContainer handlePress =
    view
        [ style
            { position = "absolute"
            , left = 0
            , top = 0
            , right = 0
            , bottom = 0
            , alignItems = "center"
            , justifyContent = "center"
            }
        ]
        [ videoPlay handlePress ]


itemView : Client -> Bool -> Metadata -> Html Msg
itemView client isContinueWatching metadata =
    let
        { label, thumb, alt } =
            case metadata.typ of
                "episode" ->
                    { thumb = metadata.grandparentThumb
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index
                    , alt = metadata.grandparentTitle
                    }

                "season" ->
                    { thumb = metadata.thumb
                    , label = "S" ++ String.fromInt metadata.parentIndex
                    , alt = metadata.parentTitle
                    }

                _ ->
                    { thumb = metadata.thumb
                    , label = formatDuration metadata.duration
                    , alt = metadata.title
                    }

        progress =
            toFloat metadata.viewOffset / toFloat metadata.duration
    in
    touchableOpacity
        [ if isContinueWatching then
            style homeStyles.itemContainer

          else
            style <| StyleSheet.compose homeStyles.itemContainer homeStyles.itemContainerBottomRadius
        , onPress <| Decode.succeed <| GotoEntity isContinueWatching metadata
        ]
        [ view
            [ style homeStyles.itemImageAlt ]
            [ text [ style homeStyles.itemImageAltText ] [ str alt ] ]
        , imageBackground
            [ style homeStyles.itemImage
            , source
                { uri = pathToAuthedUrl thumb client
                , width = 480
                , height = 719
                }
            , if isContinueWatching then
                imageStyle
                    { borderTopLeftRadius = 4
                    , borderTopRightRadius = 4
                    }

              else
                imageStyle
                    { borderRadius = 4
                    }
            ]
          <|
            if isContinueWatching then
                [ vidoePlayContainer (Decode.succeed NoOp)
                , itemLabel label
                ]

            else
                []
        , if isContinueWatching then
            view [ style homeStyles.progress, style { width = percentFloat progress } ] []

          else
            null
        ]


sectionView : Client -> Section -> Html Msg
sectionView client section =
    let
        isContinueWatching =
            section.hubIdentifier == "home.continue"
    in
    view [ style homeStyles.sectionContainer ]
        [ text [ style homeStyles.sectionTitle ] [ str section.title ]
        , scrollView
            [ contentContainerStyle homeStyles.sectionContent
            , showsHorizontalScrollIndicator False
            , horizontal True
            ]
            (List.map (itemView client isContinueWatching) section.data)
        ]


retryGetSections : String -> Html Msg
retryGetSections s =
    button [ title s, onPress <| Decode.succeed ReloadSections, color themeColor ] []


homeScreen : HomeModel -> a -> Html Msg
homeScreen model _ =
    case model.sections of
        Just (Ok ss) ->
            let
                sections =
                    List.filter (\s -> (not <| List.isEmpty s.data) && s.hubIdentifier /= "home.ondeck") ss
            in
            if List.isEmpty sections then
                view []
                    [ image [ source <| require "./assets/norecords.png", style { width = 60, height = 80 } ] []
                    , retryGetSections "Reload"
                    ]

            else
                scrollView
                    [ persistentScrollbar False
                    , contentContainerStyle homeStyles.container
                    , style { backgroundColor = backgroundColor }
                    ]
                <|
                    List.map (sectionView model.client) <|
                        sections

        Just (Err err) ->
            let
                _ =
                    Debug.log "err" err
            in
            view [ style homeStyles.loading ]
                [ ionicon "alert-circle-outline" [ size 60, color "darkred" ]
                , retryGetSections "Retry"
                ]

        _ ->
            view
                [ style homeStyles.loading ]
                [ activityIndicator [] [] ]


avatarStyles size =
    StyleSheet.create
        { container =
            { width = size
            , height = size
            , borderRadius = 5
            , backgroundColor = themeColor
            , justifyContent = "center"
            , alignItems = "center"
            , textAlign = "center"
            , textAlignVertical = "center"
            }
        , text =
            { fontSize = size
            , fontWeight = "bold"
            , color = "white"
            , lineHeight = size
            }
        }


avatar : Account -> b -> Html msg
avatar account size =
    let
        styles =
            avatarStyles size
    in
    if String.isEmpty account.thumb then
        view
            [ style styles.container ]
            [ text
                [ style styles.text ]
                [ str <| String.slice 0 1 account.name ]
            ]

    else
        image
            [ source
                { uri = account.thumb
                , width = size
                , height = size
                , borderRadius = 5
                }
            ]
            []


accountScreen : HomeModel -> a -> Html Msg
accountScreen model _ =
    view
        [ style
            { backgroundColor = backgroundColor
            , height = "100%"
            , width = "100%"
            , alignItems = "center"
            , paddingTop = 20
            }
        ]
        [ avatar model.account 64
        , scrollView [ contentContainerStyle { width = "100%", alignItems = "center" } ]
            [ view
                []
                [ button
                    [ color "white"
                    , title "Sign Out"
                    , onPress <| Decode.succeed SignOut
                    ]
                    []
                ]
            , view []
                [ text [ style { color = "white" } ] [ str "Version 0.1" ] ]
            ]
        ]


favicon : a -> Html msg
favicon size =
    image
        [ source <| require "./assets/plex-favicon.png"
        , style { width = size, height = size }
        ]
        []


quotRem : Int -> Int -> ( Int, Int )
quotRem a b =
    ( a // b, remainderBy b a )


formatDuration : Int -> String
formatDuration duration =
    let
        ( h, ms ) =
            quotRem duration (3600 * 1000)

        ( m, ms2 ) =
            quotRem ms (60 * 1000)

        s =
            ms2 // 1000
    in
    if h == 0 && m == 0 && s > 0 then
        String.fromInt s ++ "s"

    else if h == 0 && m > 0 then
        String.fromInt m ++ "m"

    else if h > 0 && m == 0 then
        String.fromInt h ++ "h"

    else
        String.fromInt h ++ "h " ++ String.fromInt m ++ "m"


progressBar : List (Html.Attribute msg) -> Float -> Html msg
progressBar props p =
    view
        (style
            { backgroundColor = "gray"
            , height = 3
            }
            :: props
        )
        [ view
            [ style
                { width = percentFloat p
                , backgroundColor = themeColor
                , height = "100%"
                }
            ]
            []
        ]


entityScreen : HomeModel -> { isContinueWatching : Bool, metadata : Metadata } -> Html Msg
entityScreen model { isContinueWatching, metadata } =
    let
        client =
            model.client

        { title, label, showProgress, showPlayButton, showId, showEpisodes } =
            case metadata.typ of
                "episode" ->
                    { title = metadata.grandparentTitle
                    , showId = metadata.grandparentRatingKey
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index ++ " " ++ metadata.title
                    , showProgress = isContinueWatching
                    , showPlayButton = True
                    , showEpisodes = True
                    }

                "season" ->
                    { title = metadata.parentTitle
                    , showId = metadata.parentRatingKey
                    , label = "S" ++ String.fromInt metadata.index
                    , showProgress = False
                    , showPlayButton = False
                    , showEpisodes = True
                    }

                "show" ->
                    { title = metadata.title
                    , showId = metadata.ratingKey
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , showEpisodes = True
                    }

                "movie" ->
                    { title = metadata.title
                    , showId = ""
                    , label = ""
                    , showProgress = isContinueWatching
                    , showPlayButton = True
                    , showEpisodes = False
                    }

                _ ->
                    { title = metadata.title
                    , showId = ""
                    , label = ""
                    , showProgress = False
                    , showPlayButton = False
                    , showEpisodes = False
                    }
    in
    view
        [ style
            { backgroundColor = backgroundColor
            , width = "100%"
            , height = "100%"
            }
        ]
        [ image
            [ source
                { uri = pathToAuthedUrl metadata.thumb client
                , width = 480
                , height = 719
                }
            , style { height = 210, width = "100%" }
            ]
            []
        , scrollView
            [ contentContainerStyle
                { paddingHorizontal = 10
                }
            ]
            [ text
                [ style
                    { fontSize = 18
                    , fontWeight = "bold"
                    , color = "white"
                    , marginTop = 10
                    }
                ]
                [ str title ]
            , view [ style { flexDirection = "row", marginTop = 10 } ]
                [ text
                    [ style
                        { color = "white"
                        , fontSize = 12
                        }
                    ]
                    [ str <| String.slice 0 4 metadata.originallyAvailableAt ]
                , if String.isEmpty metadata.contentRating then
                    null

                  else
                    view
                        [ style
                            { backgroundColor = "gray"
                            , borderRadius = 2
                            , padding = 2
                            , marginLeft = 2
                            , alignItems = "center"
                            , justifyContent = "center"
                            }
                        ]
                        [ text
                            [ style
                                { color = "white"
                                , fontSize = 8
                                , fontWeight = "bold"
                                }
                            ]
                            [ str metadata.contentRating
                            ]
                        ]
                , if metadata.duration == 0 then
                    null

                  else
                    text [ style { color = "white", marginLeft = 2, fontSize = 12 } ] [ str <| formatDuration metadata.duration ]
                ]
            , if showPlayButton then
                touchableOpacity []
                    [ view
                        [ style
                            { justifyContent = "center"
                            , alignItems = "center"
                            , backgroundColor = "white"
                            , borderRadius = 3
                            , height = 35
                            , marginTop = 15
                            , flexDirection = "row"
                            }
                        ]
                        [ text [ style { color = "black", fontSize = 30, top = 2, right = 2 } ] [ str "⏵" ]
                        , text [ style { color = "black", fontWeight = "bold" } ]
                            [ str <|
                                if isContinueWatching then
                                    " Resume"

                                else
                                    "Play"
                            ]
                        ]
                    ]

              else
                null
            , if String.isEmpty label then
                null

              else
                text
                    [ style
                        { color = "white"
                        , fontWeight = "bold"
                        , fontSize = 15
                        , marginTop = 10
                        }
                    ]
                    [ str label ]
            , if showProgress then
                let
                    progress =
                        toFloat metadata.viewOffset / toFloat metadata.duration

                    remainingDuration =
                        formatDuration (metadata.duration - metadata.viewOffset) ++ " remaining"
                in
                view
                    [ style
                        { flexDirection = "row"
                        , alignItems = "center"
                        , justifyContent = "space-between"
                        , marginTop =
                            if String.isEmpty label then
                                20

                            else
                                10
                        }
                    ]
                    [ view
                        [ style
                            { backgroundColor = "gray"
                            , height = 3
                            , flexGrow = 1
                            , marginRight = 10
                            }
                        ]
                        [ view
                            [ style
                                { width = percentFloat progress
                                , backgroundColor = themeColor
                                , height = "100%"
                                }
                            ]
                            []
                        ]
                    , text [ style { color = "gray", fontSize = 9 } ] [ str remainingDuration ]
                    ]

              else
                null
            , text
                [ style
                    { fontSize = 12
                    , color = "white"
                    , marginTop = 5
                    }
                ]
                [ str metadata.summary ]
            , if showEpisodes then
                case Dict.get showId model.tvShows of
                    Just (Ok show) ->
                        case findSeason show.selectedSeason show of
                            Just selectedSeason ->
                                view [ style { marginTop = 20 } ]
                                    [ touchableOpacity
                                        [ onPress <|
                                            Decode.succeed
                                                (ShowPicker
                                                    (List.map
                                                        (\sz ->
                                                            ( "Season" ++ String.fromInt sz.info.index, ChangeSeason showId sz.info.ratingKey )
                                                        )
                                                        show.seasons
                                                    )
                                                )
                                        , style { flexDirection = "row", alignItems = "center" }
                                        ]
                                        [ text
                                            [ style
                                                { fontWeight = "bold"
                                                , color = "white"
                                                , marginRight = 5
                                                }
                                            ]
                                            [ str <| "Season " ++ String.fromInt selectedSeason.info.index ]
                                        , ionicon "chevron-down-outline" [ size 12, color "white" ]
                                        ]
                                    , case selectedSeason.episodes of
                                        Just (Ok eps) ->
                                            view
                                                [ style { marginTop = 20 } ]
                                                (List.map
                                                    (\ep ->
                                                        view []
                                                            [ view [ style { flexDirection = "row", marginTop = 15, alignItems = "center" } ]
                                                                [ imageBackground
                                                                    [ source
                                                                        { uri = pathToAuthedUrl ep.thumb client
                                                                        , width = 720
                                                                        , height = 404
                                                                        }
                                                                    , style { width = 122, height = 65, justifyContent = "flex-end" }
                                                                    , imageStyle { borderRadius = 4, resizeMode = "contain" }
                                                                    ]
                                                                    [ vidoePlayContainer (Decode.succeed NoOp)
                                                                    , if ep.viewOffset <= 0 then
                                                                        null

                                                                      else
                                                                        progressBar [ style { width = 116, marginHorizontal = 3 } ] (toFloat ep.viewOffset / toFloat ep.duration)
                                                                    ]
                                                                , view [ style { marginLeft = 3 } ]
                                                                    [ text
                                                                        [ style
                                                                            { color = "white"
                                                                            , marginRight = 10
                                                                            }
                                                                        ]
                                                                        [ str <| String.fromInt ep.index ++ ". " ++ ep.title ]
                                                                    , text [ style { color = "gray", fontSize = 12, marginTop = 3 } ] [ str <| formatDuration ep.duration ]
                                                                    ]
                                                                ]
                                                            , text [ style { color = "gray", fontSize = 12, marginTop = 4 } ] [ str ep.summary ]
                                                            ]
                                                    )
                                                    eps
                                                )

                                        Just (Err _) ->
                                            view []
                                                [ text [] [ str "Load episodes error" ]
                                                ]

                                        _ ->
                                            view
                                                [ style
                                                    { height = 50
                                                    , justifyContent = "center"
                                                    , alignItems = "center"
                                                    }
                                                ]
                                                [ activityIndicator [] [] ]
                                    ]

                            _ ->
                                null

                    Just (Err _) ->
                        view [ style { marginTop = 20 } ]
                            [ text [] [ str "Load show error" ]
                            ]

                    _ ->
                        view
                            [ style
                                { height = 50
                                , justifyContent = "center"
                                , alignItems = "center"
                                , marginTop = 20
                                }
                            ]
                            [ activityIndicator [] [] ]

              else
                null
            , view [ style { height = 70, width = "100%" } ] []
            ]
        ]


root : Model -> Html Msg
root model =
    case model of
        Initial _ ->
            null

        SignIn m ->
            signInScreen m

        Home m ->
            stackNavigator "Main" [ componentModel m ] <|
                [ screen
                    [ name "home"
                    , options
                        { headerTitle = "Home"
                        , headerLeft = \_ -> favicon 20
                        , headerRight =
                            \_ ->
                                touchableOpacity
                                    [ onPress <| Decode.succeed GotoAccount ]
                                    [ avatar m.account 24 ]
                        , headerTintColor = "white"
                        , headerStyle = { backgroundColor = backgroundColor }
                        }
                    , component homeScreen
                    ]
                    []
                , screen
                    [ name "account"
                    , options
                        { headerTitle = ""
                        , headerBackTitle = m.account.name
                        , headerTintColor = "white"
                        , headerStyle = { backgroundColor = backgroundColor }
                        }
                    , component accountScreen
                    ]
                    []
                , screen
                    [ name "entity"
                    , options
                        { presentation = "formSheet"
                        , headerShown = False
                        }
                    , getId (\{ params } -> params.guid)
                    , component entityScreen
                    ]
                    []
                ]


subs : a -> Sub msg
subs _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ key -> init key
        , view =
            \model ->
                { title = ""
                , body =
                    [ root model ]
                }
        , update = update
        , subscriptions = subs
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }
