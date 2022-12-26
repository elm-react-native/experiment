module All exposing (..)

import AnimationExample
import AppStateExample
import Browser
import Browser.Navigation as N
import ButtonExample
import Html exposing (Html)
import Json.Decode as Decode
import PanResponderExample
import PlatformColorExample
import ReactNative exposing (button, pressable, safeAreaView, text, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Navigation as Nav
import ReactNative.Navigation.Stack as Stack
import ReactNative.Properties exposing (component, getId, initialParams, name, options, style, title)
import ReactNative.StyleSheet as StyleSheet
import StackNavigatorExample
import VibrationExample
import VirtualListExample



{- TODO
   type alias ExampleApp =
       { init : () -> ( ExampleModel, Cmd ExampleMsg )
       , update : ExampleMsg -> ExampleModel -> ( ExampleModel, Cmd ExampleMsg )
       , root : ExampleModel -> Html ExampleMsg
       , id : String
       }


   examples : List ExampleApp
   examples =
       [ { id = "AnimationExample"
         , init =
               \() ->
                   let
                       ( newModel, cmd ) =
                           AnimationExample.init ()
                   in
                   ( AnimationExample newModel, Cmd.map AnimationExampleMsg cmd )
         , update =
               \msg model ->
                   case msg of
                       AnimationExampleMsg msg2 ->
                           case model of
                               AnimationExample model2 ->
                                   let
                                       ( newModel, cmd ) =
                                           AnimationExample.update msg2 model2
                                   in
                                   ( AnimationExample newModel, Cmd.map AnimationExampleMsg cmd )

                               _ ->
                                   ( model, Cmd.none )

                       _ ->
                           ( model, Cmd.none )
         , root =
               \model ->
                   case model of
                       AnimationExample model2 ->
                           Html.map AnimationExampleMsg <| AnimationExample.root model2

                       _ ->
                           empty
         }
       ]
-}
-- MODEL


type ExampleModel
    = AnimationExample AnimationExample.Model
    | ButtonExample ButtonExample.Model
    | PanResponderExample PanResponderExample.Model
    | PlatformColorExample PlatformColorExample.Model
    | StackNavigatorExample StackNavigatorExample.Model
    | VibrationExample VibrationExample.Model
    | VirtualListExample VirtualListExample.Model
    | AppStateExample AppStateExample.Model


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
            [ { id = "AnimationExample", title = "Animation Example", key = key }
            , { id = "ButtonExample", title = "Button Example", key = key }
            , { id = "PanResponderExample", title = "PanResponder Example", key = key }
            , { id = "PlatformColorExample", title = "PlatformColor Example", key = key }
            , { id = "StackNavigatorExample", title = "StackNavigator Example", key = key }
            , { id = "VibrationExample", title = "Vibration Example", key = key }
            , { id = "VirtualListExample", title = "VirtualList Example", key = key }
            , { id = "AppStateExample", title = "AppState Example", key = key }
            ]
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
    | VirtualListExampleMsg VirtualListExample.Msg
    | AppStateExampleMsg AppStateExample.Msg


type ExampleListMsg
    = GotoExample ExampleInfo


type Msg
    = NoOp
    | ExampleMsg ExampleMsg
    | ExampleListMsg ExampleListMsg


updateList : ExampleListMsg -> Model -> ( Model, Cmd Msg )
updateList msg model =
    case msg of
        GotoExample info ->
            let
                ( exampleModel, exampleCmd ) =
                    initExample info
            in
            ( { model | detail = Just ( info, exampleModel ) }
            , Cmd.batch [ Nav.push info.key "ExampleDetails" { exampleId = info.id }, Cmd.map ExampleMsg exampleCmd ]
            )


initExample : ExampleInfo -> ( ExampleModel, Cmd ExampleMsg )
initExample info =
    let
        fromExampleCmd tagger tagger1 ( model, cmd ) =
            ( tagger model, Cmd.map tagger1 cmd )
    in
    case info.id of
        "AnimationExample" ->
            fromExampleCmd AnimationExample AnimationExampleMsg <| AnimationExample.init ()

        "ButtonExample" ->
            fromExampleCmd ButtonExample ButtonExampleMsg <| ButtonExample.init ()

        "PanResponderExample" ->
            fromExampleCmd PanResponderExample PanResponderExampleMsg <| PanResponderExample.init ()

        "PlatformColorExample" ->
            fromExampleCmd PlatformColorExample PlatformColorExampleMsg <| PlatformColorExample.init ()

        "StackNavigatorExample" ->
            fromExampleCmd StackNavigatorExample StackNavigatorExampleMsg <| StackNavigatorExample.init info.key

        "VibrationExample" ->
            fromExampleCmd VibrationExample VibrationExampleMsg <| VibrationExample.init ()

        "VirtualListExample" ->
            fromExampleCmd VirtualListExample VirtualListExampleMsg <| VirtualListExample.init ()

        _ ->
            fromExampleCmd AppStateExample AppStateExampleMsg <| AppStateExample.init ()


updateExample : ExampleMsg -> ( ExampleInfo, ExampleModel ) -> ( ExampleModel, Cmd ExampleMsg )
updateExample msg ( info, model ) =
    let
        fromExampleCmd tagger tagger1 ( exampleModel, cmd ) =
            ( tagger exampleModel, Cmd.map tagger1 cmd )
    in
    case msg of
        AnimationExampleMsg m ->
            case model of
                AnimationExample exampleModel ->
                    fromExampleCmd AnimationExample AnimationExampleMsg <| AnimationExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        ButtonExampleMsg m ->
            case model of
                ButtonExample exampleModel ->
                    fromExampleCmd ButtonExample ButtonExampleMsg <| ButtonExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        PanResponderExampleMsg m ->
            case model of
                PanResponderExample exampleModel ->
                    fromExampleCmd PanResponderExample PanResponderExampleMsg <| PanResponderExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        PlatformColorExampleMsg m ->
            case model of
                PlatformColorExample exampleModel ->
                    fromExampleCmd PlatformColorExample PlatformColorExampleMsg <| PlatformColorExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        StackNavigatorExampleMsg m ->
            case model of
                StackNavigatorExample exampleModel ->
                    fromExampleCmd StackNavigatorExample StackNavigatorExampleMsg <| StackNavigatorExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        VibrationExampleMsg m ->
            case model of
                VibrationExample exampleModel ->
                    fromExampleCmd VibrationExample VibrationExampleMsg <| VibrationExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        VirtualListExampleMsg m ->
            case model of
                VirtualListExample exampleModel ->
                    fromExampleCmd VirtualListExample VirtualListExampleMsg <| VirtualListExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )

        AppStateExampleMsg m ->
            case model of
                AppStateExample exampleModel ->
                    fromExampleCmd AppStateExample AppStateExampleMsg <| AppStateExample.update m exampleModel

                _ ->
                    ( model, Cmd.none )


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
                    let
                        ( exampleModel2, exampleCmd ) =
                            updateExample exampleMsg detail
                    in
                    ( { model | detail = Just ( Tuple.first detail, exampleModel2 ) }, Cmd.map ExampleMsg exampleCmd )

                _ ->
                    ( model, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { list =
            { display = "flex"
            , flexDirection = "column"
            , alignItems = "left"
            , paddingTop = 20
            }
        , item =
            { marginTop = 10
            }
        }


empty =
    view [] []


root : Model -> Html Msg
root model =
    Stack.navigator [] <|
        [ Stack.screen
            [ name "List"
            , component listScreen
            , options { title = "Examples" }
            ]
            []
        , Stack.screen
            [ name "ExampleDetails"
            , component detailsScreen
            , getId (\{ params } -> params.exampleId)
            , options
                { title =
                    case model.detail of
                        Just ( exampleInfo, _ ) ->
                            exampleInfo.title

                        _ ->
                            ""
                }
            ]
            []
        ]


detailsScreen model _ =
    case model.detail of
        Just ( exampleInfo, exampleModel ) ->
            detailsRoot exampleModel

        _ ->
            empty


detailsRoot : ExampleModel -> Html Msg
detailsRoot model =
    case model of
        AnimationExample m ->
            Html.map (ExampleMsg << AnimationExampleMsg) <| AnimationExample.root m

        ButtonExample m ->
            Html.map (ExampleMsg << ButtonExampleMsg) <| ButtonExample.root m

        PanResponderExample m ->
            Html.map (ExampleMsg << PanResponderExampleMsg) <| PanResponderExample.root m

        PlatformColorExample m ->
            Html.map (ExampleMsg << PlatformColorExampleMsg) <| PlatformColorExample.root m

        StackNavigatorExample m ->
            Html.map (ExampleMsg << StackNavigatorExampleMsg) <| StackNavigatorExample.root m

        VibrationExample m ->
            Html.map (ExampleMsg << VibrationExampleMsg) <| VibrationExample.root m

        VirtualListExample m ->
            Html.map (ExampleMsg << VirtualListExampleMsg) <| VirtualListExample.root m

        AppStateExample m ->
            Html.map (ExampleMsg << AppStateExampleMsg) <| AppStateExample.root m


exampleItem info =
    button
        [ title info.title
        , style styles.item
        , onPress (Decode.succeed <| ExampleListMsg <| GotoExample info)
        ]
        []


listScreen model _ =
    safeAreaView []
        [ view
            [ style styles.list ]
            (List.map exampleItem model.list)
        ]


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ key -> init key
        , view =
            \model ->
                { title = ""
                , body = [ root model ]
                }
        , update = update
        , subscriptions =
            \model ->
                case model.detail of
                    Just ( exampleInfo, _ ) ->
                        if exampleInfo.id == "AppStateExample" then
                            Sub.map (ExampleMsg << AppStateExampleMsg) AppStateExample.subs

                        else
                            Sub.none

                    _ ->
                        Sub.none
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }
