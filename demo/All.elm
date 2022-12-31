module All exposing (..)

import AlertExample
import AnimationExample
import AppStateExample
import AppearanceExample
import Browser
import Browser.Navigation as N
import ButtonExample
import Dict exposing (Dict)
import DimensionsExample
import EasingExample
import FlatListExample
import Html exposing (Html)
import Html.Lazy exposing (lazy)
import ImageExample
import Json.Decode as Decode
import KeyboardAvoidingViewExample
import KeyboardExample
import ModalExample
import PanResponderExample
import PlatformColorExample
import PressableExample
import ReactNative exposing (button, image, materialIcon, null, pressable, require, safeAreaView, scrollView, statusBar, str, text, touchableOpacity, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Navigation as Nav
import ReactNative.Navigation.Listeners as Listeners
import ReactNative.Navigation.Stack as Stack
import ReactNative.Properties exposing (barStyle, color, component, contentContainerStyle, getId, initialParams, name, options, size, source, style, title)
import ReactNative.StyleSheet as StyleSheet
import RefreshControlExample
import ScrollViewExample
import SectionListExample
import StackNavigatorExample
import StatusBarExample
import SwitchExample
import TextExample
import TextInputExample
import TransformsExample
import VibrationExample
import VirtualizedListExample


type alias ExampleApp model msg =
    { id : String
    , title : String
    , init : N.Key -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , root : model -> Html msg
    , subs : model -> Sub msg
    }


type alias GeneralExampleApp =
    ExampleApp ExampleModel ExampleMsg


toGeneralExampleApp :
    (model -> ExampleModel)
    -> (ExampleModel -> Maybe model)
    -> (msg -> ExampleMsg)
    -> (ExampleMsg -> Maybe msg)
    -> ExampleApp model msg
    -> GeneralExampleApp
toGeneralExampleApp modelTagger modelUntagger msgTagger msgUntagger app =
    { init =
        \key ->
            let
                ( md, cmd ) =
                    app.init key
            in
            ( modelTagger md, Cmd.map msgTagger cmd )
    , update =
        \msg model ->
            case msgUntagger msg of
                Just msg1 ->
                    case modelUntagger model of
                        Just model1 ->
                            let
                                ( md, cmd ) =
                                    app.update msg1 model1
                            in
                            ( modelTagger md, Cmd.map msgTagger cmd )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )
    , root =
        \model ->
            case modelUntagger model of
                Just model1 ->
                    Html.map msgTagger <| app.root model1

                _ ->
                    null
    , subs =
        \model ->
            case modelUntagger model of
                Just model1 ->
                    Sub.map msgTagger <| app.subs model1

                _ ->
                    Sub.none
    , id = app.id
    , title = app.title
    }


exampleApps : List GeneralExampleApp
exampleApps =
    [ toGeneralExampleApp
        AnimationExample
        (\model ->
            case model of
                AnimationExample m ->
                    Just m

                _ ->
                    Nothing
        )
        AnimationExampleMsg
        (\msg ->
            case msg of
                AnimationExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "AnimationExample"
        , title = "Animation"
        , init = \_ -> AnimationExample.init ()
        , update = AnimationExample.update
        , root = AnimationExample.root
        , subs = AnimationExample.subs
        }
    , toGeneralExampleApp
        ButtonExample
        (\model ->
            case model of
                ButtonExample m ->
                    Just m

                _ ->
                    Nothing
        )
        ButtonExampleMsg
        (\msg ->
            case msg of
                ButtonExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "ButtonExample"
        , title = "Button"
        , init = \_ -> ButtonExample.init ()
        , update = ButtonExample.update
        , root = ButtonExample.root
        , subs = ButtonExample.subs
        }
    , toGeneralExampleApp
        AlertExample
        (\model ->
            case model of
                AlertExample m ->
                    Just m

                _ ->
                    Nothing
        )
        AlertExampleMsg
        (\msg ->
            case msg of
                AlertExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "AlertExample"
        , title = "Alert"
        , init = \_ -> AlertExample.init ()
        , update = AlertExample.update
        , root = AlertExample.root
        , subs = AlertExample.subs
        }
    , toGeneralExampleApp
        AppStateExample
        (\model ->
            case model of
                AppStateExample m ->
                    Just m

                _ ->
                    Nothing
        )
        AppStateExampleMsg
        (\msg ->
            case msg of
                AppStateExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "AppStateExample"
        , title = "AppState"
        , init = \_ -> AppStateExample.init ()
        , update = AppStateExample.update
        , root = AppStateExample.root
        , subs = AppStateExample.subs
        }
    , toGeneralExampleApp
        DimensionsExample
        (\model ->
            case model of
                DimensionsExample m ->
                    Just m

                _ ->
                    Nothing
        )
        DimensionsExampleMsg
        (\msg ->
            case msg of
                DimensionsExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "DimensionsExample"
        , title = "Dimensions"
        , init = \_ -> DimensionsExample.init ()
        , update = DimensionsExample.update
        , root = DimensionsExample.root
        , subs = DimensionsExample.subs
        }
    , toGeneralExampleApp
        EasingExample
        (\model ->
            case model of
                EasingExample m ->
                    Just m

                _ ->
                    Nothing
        )
        EasingExampleMsg
        (\msg ->
            case msg of
                EasingExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "EasingExample"
        , title = "Easing"
        , init = \_ -> EasingExample.init ()
        , update = EasingExample.update
        , root = EasingExample.root
        , subs = EasingExample.subs
        }
    , toGeneralExampleApp
        ImageExample
        (\model ->
            case model of
                ImageExample m ->
                    Just m

                _ ->
                    Nothing
        )
        ImageExampleMsg
        (\msg ->
            case msg of
                ImageExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "ImageExample"
        , title = "Image"
        , init = \_ -> ImageExample.init ()
        , update = ImageExample.update
        , root = ImageExample.root
        , subs = ImageExample.subs
        }
    , toGeneralExampleApp
        KeyboardAvoidingViewExample
        (\model ->
            case model of
                KeyboardAvoidingViewExample m ->
                    Just m

                _ ->
                    Nothing
        )
        KeyboardAvoidingViewExampleMsg
        (\msg ->
            case msg of
                KeyboardAvoidingViewExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "KeyboardAvoidingViewExample"
        , title = "KeyboardAvoidingView"
        , init = \_ -> KeyboardAvoidingViewExample.init ()
        , update = KeyboardAvoidingViewExample.update
        , root = KeyboardAvoidingViewExample.root
        , subs = KeyboardAvoidingViewExample.subs
        }
    , toGeneralExampleApp
        KeyboardExample
        (\model ->
            case model of
                KeyboardExample m ->
                    Just m

                _ ->
                    Nothing
        )
        KeyboardExampleMsg
        (\msg ->
            case msg of
                KeyboardExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "KeyboardExample"
        , title = "Keyboard"
        , init = \_ -> KeyboardExample.init ()
        , update = KeyboardExample.update
        , root = KeyboardExample.root
        , subs = KeyboardExample.subs
        }
    , toGeneralExampleApp
        ModalExample
        (\model ->
            case model of
                ModalExample m ->
                    Just m

                _ ->
                    Nothing
        )
        ModalExampleMsg
        (\msg ->
            case msg of
                ModalExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "ModalExample"
        , title = "Modal"
        , init = \_ -> ModalExample.init ()
        , update = ModalExample.update
        , root = ModalExample.root
        , subs = ModalExample.subs
        }
    , toGeneralExampleApp
        PanResponderExample
        (\model ->
            case model of
                PanResponderExample m ->
                    Just m

                _ ->
                    Nothing
        )
        PanResponderExampleMsg
        (\msg ->
            case msg of
                PanResponderExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "PanResponderExample"
        , title = "PanResponder"
        , init = \_ -> PanResponderExample.init ()
        , update = PanResponderExample.update
        , root = PanResponderExample.root
        , subs = PanResponderExample.subs
        }
    , toGeneralExampleApp
        PlatformColorExample
        (\model ->
            case model of
                PlatformColorExample m ->
                    Just m

                _ ->
                    Nothing
        )
        PlatformColorExampleMsg
        (\msg ->
            case msg of
                PlatformColorExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "PlatformColorExample"
        , title = "PlatformColor"
        , init = \_ -> PlatformColorExample.init ()
        , update = PlatformColorExample.update
        , root = PlatformColorExample.root
        , subs = PlatformColorExample.subs
        }
    , toGeneralExampleApp
        RefreshControlExample
        (\model ->
            case model of
                RefreshControlExample m ->
                    Just m

                _ ->
                    Nothing
        )
        RefreshControlExampleMsg
        (\msg ->
            case msg of
                RefreshControlExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "RefreshControlExample"
        , title = "RefreshControl"
        , init = \_ -> RefreshControlExample.init ()
        , update = RefreshControlExample.update
        , root = RefreshControlExample.root
        , subs = RefreshControlExample.subs
        }
    , toGeneralExampleApp
        StackNavigatorExample
        (\model ->
            case model of
                StackNavigatorExample m ->
                    Just m

                _ ->
                    Nothing
        )
        StackNavigatorExampleMsg
        (\msg ->
            case msg of
                StackNavigatorExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "StackNavigatorExample"
        , title = "StackNavigator"
        , init = StackNavigatorExample.init
        , update = StackNavigatorExample.update
        , root = StackNavigatorExample.root
        , subs = StackNavigatorExample.subs
        }
    , toGeneralExampleApp
        StatusBarExample
        (\model ->
            case model of
                StatusBarExample m ->
                    Just m

                _ ->
                    Nothing
        )
        StatusBarExampleMsg
        (\msg ->
            case msg of
                StatusBarExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "StatusBarExample"
        , title = "StatusBar"
        , init = \_ -> StatusBarExample.init ()
        , update = StatusBarExample.update
        , root = StatusBarExample.root
        , subs = StatusBarExample.subs
        }
    , toGeneralExampleApp
        SwitchExample
        (\model ->
            case model of
                SwitchExample m ->
                    Just m

                _ ->
                    Nothing
        )
        SwitchExampleMsg
        (\msg ->
            case msg of
                SwitchExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "SwitchExample"
        , title = "Switch"
        , init = \_ -> SwitchExample.init ()
        , update = SwitchExample.update
        , root = SwitchExample.root
        , subs = SwitchExample.subs
        }
    , toGeneralExampleApp
        TextExample
        (\model ->
            case model of
                TextExample m ->
                    Just m

                _ ->
                    Nothing
        )
        TextExampleMsg
        (\msg ->
            case msg of
                TextExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "TextExample"
        , title = "Text"
        , init = \_ -> TextExample.init ()
        , update = TextExample.update
        , root = TextExample.root
        , subs = TextExample.subs
        }
    , toGeneralExampleApp
        TextInputExample
        (\model ->
            case model of
                TextInputExample m ->
                    Just m

                _ ->
                    Nothing
        )
        TextInputExampleMsg
        (\msg ->
            case msg of
                TextInputExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "TextInputExample"
        , title = "TextInput"
        , init = \_ -> TextInputExample.init ()
        , update = TextInputExample.update
        , root = TextInputExample.root
        , subs = TextInputExample.subs
        }
    , toGeneralExampleApp
        TransformsExample
        (\model ->
            case model of
                TransformsExample m ->
                    Just m

                _ ->
                    Nothing
        )
        TransformsExampleMsg
        (\msg ->
            case msg of
                TransformsExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "TransformsExample"
        , title = "Transforms"
        , init = \_ -> TransformsExample.init ()
        , update = TransformsExample.update
        , root = TransformsExample.root
        , subs = TransformsExample.subs
        }
    , toGeneralExampleApp
        VibrationExample
        (\model ->
            case model of
                VibrationExample m ->
                    Just m

                _ ->
                    Nothing
        )
        VibrationExampleMsg
        (\msg ->
            case msg of
                VibrationExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "VibrationExample"
        , title = "Vibration"
        , init = \_ -> VibrationExample.init ()
        , update = VibrationExample.update
        , root = VibrationExample.root
        , subs = VibrationExample.subs
        }
    , toGeneralExampleApp
        VirtualizedListExample
        (\model ->
            case model of
                VirtualizedListExample m ->
                    Just m

                _ ->
                    Nothing
        )
        VirtualizedListExampleMsg
        (\msg ->
            case msg of
                VirtualizedListExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "VirtualizedListExample"
        , title = "VirtualizedList"
        , init = \_ -> VirtualizedListExample.init ()
        , update = VirtualizedListExample.update
        , root = VirtualizedListExample.root
        , subs = VirtualizedListExample.subs
        }
    , toGeneralExampleApp
        ScrollViewExample
        (\model ->
            case model of
                ScrollViewExample m ->
                    Just m

                _ ->
                    Nothing
        )
        ScrollViewExampleMsg
        (\msg ->
            case msg of
                ScrollViewExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "ScrollViewExample"
        , title = "ScrollView"
        , init = \_ -> ScrollViewExample.init ()
        , update = ScrollViewExample.update
        , root = ScrollViewExample.root
        , subs = ScrollViewExample.subs
        }
    , toGeneralExampleApp
        SectionListExample
        (\model ->
            case model of
                SectionListExample m ->
                    Just m

                _ ->
                    Nothing
        )
        SectionListExampleMsg
        (\msg ->
            case msg of
                SectionListExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "SectionListExample"
        , title = "SectionList"
        , init = \_ -> SectionListExample.init ()
        , update = SectionListExample.update
        , root = SectionListExample.root
        , subs = SectionListExample.subs
        }
    , toGeneralExampleApp
        FlatListExample
        (\model ->
            case model of
                FlatListExample m ->
                    Just m

                _ ->
                    Nothing
        )
        FlatListExampleMsg
        (\msg ->
            case msg of
                FlatListExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "FlatListExample"
        , title = "FlatList"
        , init = \_ -> FlatListExample.init ()
        , update = FlatListExample.update
        , root = FlatListExample.root
        , subs = FlatListExample.subs
        }
    , toGeneralExampleApp
        PressableExample
        (\model ->
            case model of
                PressableExample m ->
                    Just m

                _ ->
                    Nothing
        )
        PressableExampleMsg
        (\msg ->
            case msg of
                PressableExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "PressableExample"
        , title = "Pressable"
        , init = \_ -> PressableExample.init ()
        , update = PressableExample.update
        , root = PressableExample.root
        , subs = PressableExample.subs
        }
    , toGeneralExampleApp
        AppearanceExample
        (\model ->
            case model of
                AppearanceExample m ->
                    Just m

                _ ->
                    Nothing
        )
        AppearanceExampleMsg
        (\msg ->
            case msg of
                AppearanceExampleMsg m ->
                    Just m

                _ ->
                    Nothing
        )
        { id = "AppearanceExample"
        , title = "Appearance"
        , init = \_ -> AppearanceExample.init ()
        , update = AppearanceExample.update
        , root = AppearanceExample.root
        , subs = AppearanceExample.subs
        }
    ]


exampleAppsDict : Dict String GeneralExampleApp
exampleAppsDict =
    exampleApps
        |> List.map (\app -> ( app.id, app ))
        |> Dict.fromList


getExampleApp : String -> Maybe GeneralExampleApp
getExampleApp id =
    Dict.get id exampleAppsDict



-- MODEL


type ExampleModel
    = AnimationExample AnimationExample.Model
    | ButtonExample ButtonExample.Model
    | PanResponderExample PanResponderExample.Model
    | PlatformColorExample PlatformColorExample.Model
    | StackNavigatorExample StackNavigatorExample.Model
    | VibrationExample VibrationExample.Model
    | VirtualizedListExample VirtualizedListExample.Model
    | AppStateExample AppStateExample.Model
    | ModalExample ModalExample.Model
    | RefreshControlExample RefreshControlExample.Model
    | EasingExample EasingExample.Model
    | StatusBarExample StatusBarExample.Model
    | DimensionsExample DimensionsExample.Model
    | KeyboardExample KeyboardExample.Model
    | TransformsExample TransformsExample.Model
    | AlertExample AlertExample.Model
    | ImageExample ImageExample.Model
    | SwitchExample SwitchExample.Model
    | TextExample TextExample.Model
    | TextInputExample TextInputExample.Model
    | KeyboardAvoidingViewExample KeyboardAvoidingViewExample.Model
    | ScrollViewExample ScrollViewExample.Model
    | SectionListExample SectionListExample.Model
    | FlatListExample FlatListExample.Model
    | PressableExample PressableExample.Model
    | AppearanceExample AppearanceExample.Model


type alias ExampleInfo =
    { id : String
    , title : String
    , key : N.Key
    }


type alias Model =
    { list : List ExampleInfo
    , detail : Maybe ( ExampleInfo, ExampleModel )
    }


init : N.Key -> ( Model, Cmd Msg )
init key =
    ( { list =
            List.map
                (\app ->
                    { id = app.id
                    , title = app.title
                    , key = key
                    }
                )
                exampleApps
      , detail = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type ExampleMsg
    = AnimationExampleMsg AnimationExample.Msg
    | ButtonExampleMsg ButtonExample.Msg
    | PanResponderExampleMsg PanResponderExample.Msg
    | PlatformColorExampleMsg PlatformColorExample.Msg
    | StackNavigatorExampleMsg StackNavigatorExample.Msg
    | VibrationExampleMsg VibrationExample.Msg
    | VirtualizedListExampleMsg VirtualizedListExample.Msg
    | AppStateExampleMsg AppStateExample.Msg
    | ModalExampleMsg ModalExample.Msg
    | RefreshControlExampleMsg RefreshControlExample.Msg
    | EasingExampleMsg EasingExample.Msg
    | StatusBarExampleMsg StatusBarExample.Msg
    | DimensionsExampleMsg DimensionsExample.Msg
    | KeyboardExampleMsg KeyboardExample.Msg
    | TransformsExampleMsg TransformsExample.Msg
    | AlertExampleMsg AlertExample.Msg
    | ImageExampleMsg ImageExample.Msg
    | SwitchExampleMsg SwitchExample.Msg
    | TextExampleMsg TextExample.Msg
    | TextInputExampleMsg TextInputExample.Msg
    | KeyboardAvoidingViewExampleMsg KeyboardAvoidingViewExample.Msg
    | ScrollViewExampleMsg ScrollViewExample.Msg
    | SectionListExampleMsg SectionListExample.Msg
    | FlatListExampleMsg FlatListExample.Msg
    | PressableExampleMsg PressableExample.Msg
    | AppearanceExampleMsg AppearanceExample.Msg


type ExampleListMsg
    = GotoExample ExampleInfo
    | FocusListScreen


type Msg
    = NoOp
    | ExampleMsg ExampleMsg
    | ExampleListMsg ExampleListMsg


updateList : ExampleListMsg -> Model -> ( Model, Cmd Msg )
updateList msg model =
    case msg of
        GotoExample info ->
            case initExample info of
                Just ( exampleModel, exampleCmd ) ->
                    ( { model | detail = Just ( info, exampleModel ) }
                    , Cmd.batch [ Nav.push info.key "ExampleDetails" { exampleId = info.id, exampleTitle = info.title }, Cmd.map ExampleMsg exampleCmd ]
                    )

                _ ->
                    ( model, Cmd.none )

        FocusListScreen ->
            ( { model | detail = Nothing }, Cmd.none )


initExample : ExampleInfo -> Maybe ( ExampleModel, Cmd ExampleMsg )
initExample info =
    info.id
        |> getExampleApp
        |> Maybe.map (\app -> app.init info.key)


updateExample : ExampleMsg -> ( ExampleInfo, ExampleModel ) -> Maybe ( ExampleModel, Cmd ExampleMsg )
updateExample msg ( info, model ) =
    info.id
        |> getExampleApp
        |> Maybe.map (\app -> app.update msg model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ExampleListMsg listMsg ->
            updateList listMsg model

        ExampleMsg exampleMsg ->
            case model.detail of
                Just detail ->
                    case updateExample exampleMsg detail of
                        Just ( exampleModel2, exampleCmd ) ->
                            ( { model | detail = Just ( Tuple.first detail, exampleModel2 ) }, Cmd.map ExampleMsg exampleCmd )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )



-- VIEW


borderColor =
    "#ccc"


styles =
    let
        borderWidth =
            StyleSheet.hairlineWidth
    in
    StyleSheet.create
        { container =
            { display = "flex"
            , alignItems = "center"
            , padding = 20
            }
        , list =
            { display = "flex"
            , alignItems = "center"
            , backgroundColor = "white"
            , width = "100%"
            , borderRadius = 10
            }
        , item =
            { height = 44
            , width = "100%"
            , flexDirection = "row"
            , alignItems = "center"
            }
        , firstItem =
            { borderTopLeftRadius = 10
            , borderTopRightRadius = 10
            }
        , lastItem =
            { borderBottomLeftRadius = 10
            , borderBottomRightRadius = 10
            }
        , itemRight =
            { borderTopWidth = borderWidth
            , borderTopColor = borderColor
            , height = "100%"
            , flexGrow = 1
            , flexDirection = "row"
            , justifyContent = "space-between"
            , alignItems = "center"
            }
        , firstItemRight = { borderTopColor = "transparent" }
        }


exampleListTitle =
    "Examples (" ++ String.fromInt (List.length exampleApps) ++ ")"


root : Model -> Html Msg
root model =
    Stack.navigator [] <|
        [ Stack.screen
            [ name "List"
            , component listScreen
            , options { title = exampleListTitle }
            , Stack.listeners [ Listeners.focus <| Decode.succeed <| ExampleListMsg FocusListScreen ]
            ]
            []
        , Stack.screen
            [ name "ExampleDetails"
            , component detailsScreen
            , getId (\{ params } -> params.exampleId)
            , options (\{ route } -> { title = route.params.exampleTitle })
            ]
            []
        ]


detailsScreen model _ =
    case model.detail of
        Just ( exampleInfo, exampleModel ) ->
            exampleInfo.id
                |> getExampleApp
                |> Maybe.map (\app -> Html.map ExampleMsg <| app.root exampleModel)
                |> Maybe.withDefault null

        _ ->
            null


exampleIcon =
    image
        [ style
            { marginHorizontal = 12
            , width = 24
            , height = 24
            }
        , source <| require "./assets/favicon.png"
        ]
        []


arrowRight =
    materialIcon "keyboard-arrow-right"
        [ style { marginHorizontal = 12 }
        , size 16
        , color "#b3b3b3"
        ]


exampleItem len i info =
    pressable
        [ onPress (Decode.succeed <| ExampleListMsg <| GotoExample info) ]
        (\{ pressed } ->
            view
                [ if len == 1 then
                    style <| StyleSheet.compose3 styles.item styles.firstItem styles.lastItem

                  else if i == 0 then
                    style <| StyleSheet.compose styles.item styles.firstItem

                  else if i == len - 1 then
                    style <| StyleSheet.compose styles.item styles.lastItem

                  else
                    style styles.item
                , style
                    { backgroundColor =
                        if pressed then
                            borderColor

                        else
                            "white"
                    }
                ]
                [ exampleIcon
                , view
                    [ if i == 0 then
                        style <| StyleSheet.compose styles.itemRight styles.firstItemRight

                      else
                        style styles.itemRight
                    ]
                    [ text [] [ str info.title ]
                    , arrowRight
                    ]
                ]
        )


exampleList list =
    safeAreaView []
        [ scrollView
            [ contentContainerStyle styles.container ]
            [ view [ style styles.list ]
                (list
                    |> List.sortBy .title
                    |> List.indexedMap (exampleItem <| List.length list)
                )
            ]
        ]


listScreen model _ =
    lazy exampleList model.list


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ key -> init key
        , view =
            \model ->
                { title = ""
                , body =
                    [ root model
                    , statusBar [ barStyle "dark-content" ] []
                    ]
                }
        , update = update
        , subscriptions =
            \model ->
                case model.detail of
                    Just ( exampleInfo, exampleModel ) ->
                        exampleInfo.id
                            |> getExampleApp
                            |> Maybe.map (\app -> Sub.map ExampleMsg <| app.subs exampleModel)
                            |> Maybe.withDefault Sub.none

                    _ ->
                        Sub.none
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }
