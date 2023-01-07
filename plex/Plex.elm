module Plex exposing (..)

import Api exposing (Account, Client, Library, Metadata, Section, Tree(..))
import Browser
import Browser.Navigation as N
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative
    exposing
        ( activityIndicator
        , button
        , fragment
        , image
        , imageBackground
        , ionicon
        , keyboardAvoidingView
        , null
        , pressable
        , require
        , safeAreaView
        , scrollView
        , sectionList
        , statusBar
        , str
        , text
        , textInput
        , touchableOpacity
        , touchableWithoutFeedback
        , view
        )
import ReactNative.Alert as Alert
import ReactNative.Events exposing (onChangeText, onPress)
import ReactNative.Keyboard as Keyboard
import ReactNative.Navigation as Nav exposing (screen, stackNavigator)
import ReactNative.Navigation.CardStyleInterpolators as CardStyleInterpolators
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Platform as Platform
import ReactNative.Properties
    exposing
        ( barStyle
        , behavior
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
import ReactNative.StyleSheet as StyleSheet
import ReactNative.Transforms exposing (rotate, scale, scaleY, transform, translateX)
import Task exposing (Task)



-- MODEL


type alias SignInModel =
    { client : Client, navKey : N.Key, submitting : Bool }


type alias RemoteData data =
    Maybe (Result Http.Error data)


type alias HomeModel =
    { continueWatching : RemoteData Section
    , recentlyAdded : RemoteData Section
    , libraries : List (RemoteData Section)
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
    | GotContinueWatching (Result Http.Error Section)
    | GotRecentlyAdded (Result Http.Error Section)
    | DismissKeyboard
    | ShowSection String
    | ShowEntity String String
    | GotoAccount
    | GotoEntity String
    | SignOut


initialClient =
    { serverAddress = "", token = "" }


signInSubmit =
    Api.getAccount SignInSubmitResponse


getContinueWatching =
    Api.getContinueWatching GotContinueWatching


saveClient client =
    Task.perform (always NoOp) <|
        Settings.set
            [ ( "serverAddress", Encode.string client.serverAddress )
            , ( "token", Encode.string client.token )
            ]


pathToAuthedUrl path client =
    client.serverAddress ++ path ++ "?X-Plex-Token=" ++ client.token


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
                        { continueWatching = Nothing
                        , recentlyAdded = Nothing
                        , libraries = []
                        , account =
                            if account.thumb == "" then
                                account

                            else
                                { account | thumb = pathToAuthedUrl account.thumb client }
                        , client = client
                        , navKey = navKey
                        }
                    , Cmd.batch [ saveClient client, getContinueWatching client ]
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

                                e ->
                                    "Network error."
                    in
                    ( SignIn { m | submitting = False }, Task.perform (always NoOp) <| Alert.alert errMessage [] )

                _ ->
                    ( model, Cmd.none )

        GotContinueWatching resp ->
            ( case model of
                Home m ->
                    Home { m | continueWatching = Just resp }

                _ ->
                    model
            , Cmd.none
            )

        GotRecentlyAdded resp ->
            ( case model of
                Home m ->
                    Home { m | recentlyAdded = Just resp }

                _ ->
                    model
            , Cmd.none
            )

        ShowSection sectionId ->
            ( model, Cmd.none )

        ShowEntity sectionId entityId ->
            ( model, Cmd.none )

        GotoAccount ->
            case model of
                Home m ->
                    ( model, Nav.push m.navKey "account" {} )

                _ ->
                    ( model, Cmd.none )

        GotoEntity guid ->
            case model of
                Home m ->
                    ( model, Nav.push m.navKey "entity" { guid = guid } )

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



-- VIEW


themeColor =
    "#EBAF00"


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
signInScreen { client, navKey, submitting } =
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
                            || (client.serverAddress == "")
                            || (client.token == "")
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
        { container = { height = "100%", backgroundColor = backgroundColor }
        , sectionContainer =
            { height = 180, paddingVertical = 5 }
        , sectionTitle =
            { fontSize = 15
            , fontWeight = "bold"
            , color = "white"
            , marginLeft = 5
            , marginBottom = 2
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
            , borderTopLeftRadius = 4
            , borderTopRightRadius = 4
            , overflow = "hidden"
            , width = 100
            , height = 149
            }
        , itemImage =
            { justifyContent = "flex-end"
            , width = 100
            , height = 146
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
            }
        , progress =
            { backgroundColor = themeColor
            , height = 3
            }
        }


percentFloat f =
    (String.fromInt <| ceiling <| f * 100) ++ "%"


itemLabel label =
    imageBackground
        [ style homeStyles.itemLabelBackground
        , source <| require "./assets/gradient.png"
        , imageStyle { resizeMode = "repeat" }
        ]
        [ text [ style homeStyles.itemLabel ]
            [ str label ]
        ]


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


itemView : Client -> Tree Metadata -> Html Msg
itemView client item =
    let
        metadata =
            case item of
                Branch meta _ ->
                    meta

                Leaf meta ->
                    meta

        { label, thumb, alt } =
            case metadata.typ of
                "episode" ->
                    { thumb = metadata.grandparentThumb
                    , label = "S" ++ String.fromInt metadata.parentIndex ++ ":E" ++ String.fromInt metadata.index
                    , alt = metadata.grandparentTitle
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
        [ style homeStyles.itemContainer
        , onPress <| Decode.succeed <| GotoEntity metadata.guid
        ]
        [ view [ style homeStyles.itemImageAlt ] [ text [ style homeStyles.itemImageAltText ] [ str alt ] ]
        , imageBackground
            [ style homeStyles.itemImage
            , source
                { uri = pathToAuthedUrl thumb client
                , width = 480
                , height = 719
                }
            , imageStyle { resizeMode = "cover" }
            ]
            [ vidoePlayContainer (Decode.succeed NoOp)
            , itemLabel label
            ]
        , view [ style homeStyles.progress, style { width = percentFloat progress } ] []
        ]


sectionView : Client -> RemoteData Section -> Html Msg
sectionView client data =
    case data of
        Just (Ok section) ->
            view [ style homeStyles.sectionContainer ]
                [ text [ style homeStyles.sectionTitle ] [ str section.title ]
                , scrollView
                    [ contentContainerStyle homeStyles.sectionContent
                    , showsHorizontalScrollIndicator False
                    , horizontal True
                    ]
                    (List.map (itemView client) section.data)
                ]

        Just (Err _) ->
            text [] [ str "Load Error" ]

        _ ->
            null



--view
--    [ style homeStyles.sectionContent
--    , style homeStyles.sectionContentLoading
--    , style homeStyles.sectionContainer
--    ]
--    [ activityIndicator [] []
--    ]


homeScreen model _ =
    scrollView
        [ persistentScrollbar False
        , contentContainerStyle homeStyles.container
        , style { backgroundColor = backgroundColor }
        ]
        (List.map (sectionView model.client) <| [ model.continueWatching, model.recentlyAdded ] ++ model.libraries)


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


avatar account size =
    let
        styles =
            avatarStyles size
    in
    if account.thumb == "" then
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


favicon size =
    image
        [ source <| require "./assets/plex-favicon.png"
        , style { width = size, height = size }
        ]
        []


quotRem a b =
    ( a // b, remainderBy b a )


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


entityScreen : HomeModel -> { guid : String } -> Html Msg
entityScreen { client, continueWatching } { guid } =
    let
        maybeMeta =
            case continueWatching of
                Just (Ok section) ->
                    section.data
                        |> List.filterMap
                            (\item ->
                                let
                                    metadata =
                                        case item of
                                            Branch meta _ ->
                                                meta

                                            Leaf meta ->
                                                meta
                                in
                                if metadata.guid == guid then
                                    Just metadata

                                else
                                    Nothing
                            )
                        |> List.head

                _ ->
                    Nothing
    in
    case maybeMeta of
        Just meta ->
            let
                progress =
                    toFloat meta.viewOffset / toFloat meta.duration

                remainingDuration =
                    formatDuration (meta.duration - meta.viewOffset) ++ " remaining"

                { title, label } =
                    case meta.typ of
                        "episode" ->
                            { title = meta.grandparentTitle
                            , label = "S" ++ String.fromInt meta.parentIndex ++ ":E" ++ String.fromInt meta.index ++ " " ++ meta.title
                            }

                        _ ->
                            { title = meta.title
                            , label = ""
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
                        { uri = pathToAuthedUrl meta.thumb client
                        , width = "100%"
                        , height = 210
                        }
                    ]
                    []
                , scrollView
                    [ contentContainerStyle { paddingHorizontal = 10 } ]
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
                            [ str <| String.slice 0 4 meta.originallyAvailableAt ]
                        , if meta.contentRating == "" then
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
                                    [ str meta.contentRating
                                    ]
                                ]
                        , text [ style { color = "white", marginLeft = 2, fontSize = 12 } ] [ str <| formatDuration meta.duration ]
                        ]
                    , touchableOpacity []
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
                            , text [ style { color = "black", fontWeight = "bold" } ] [ str " Resume" ]
                            ]
                        ]
                    , if label == "" then
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
                    , view
                        [ style
                            { flexDirection = "row"
                            , alignItems = "center"
                            , justifyContent = "space-between"
                            , marginTop =
                                if label == "" then
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
                    , text
                        [ style
                            { fontSize = 12
                            , color = "white"
                            , marginTop = 5
                            }
                        ]
                        [ str meta.summary ]
                    ]
                ]

        _ ->
            null


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
