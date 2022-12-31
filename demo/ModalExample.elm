module ModalExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (button, image, modal, pressable, require, safeAreaView, str, text, view)
import ReactNative.Alert as Alert exposing (alert)
import ReactNative.Events exposing (onClick, onPress, onRefresh, onRequestClose)
import ReactNative.Properties exposing (animationType, color, disabled, presentationStyle, source, style, title, transparent, visible)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    { modalOpen : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { modalOpen = False }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ShowModal
    | CloseModal
    | ModalClosing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ShowModal ->
            ( { model | modalOpen = True }, Cmd.none )

        CloseModal ->
            ( { model | modalOpen = False }, Cmd.none )

        ModalClosing ->
            let
                _ =
                    Debug.log "ModalClosing" "ModalClosing"
            in
            ( { model | modalOpen = False }, Alert.show (always NoOp) <| alert "Modal has been closed." )



-- VIEW


styles =
    StyleSheet.create
        { centeredView =
            { flex = 1
            , justifyContent = "center"
            , alignItems = "center"
            , marginTop = 22
            }
        , modalView =
            { margin = 20
            , backgroundColor = "white"
            , borderRadius = 20
            , padding = 35
            , alignItems = "center"
            , shadowColor = "#000"
            , shadowOffset =
                { width = 0
                , height = 2
                }
            , shadowOpacity = 0.25
            , shadowRadius = 4
            , elevation = 5
            }
        , button =
            { borderRadius = 20
            , padding = 10
            , elevation = 2
            }
        , buttonOpen =
            { backgroundColor = "#F194FF"
            }
        , buttonClose =
            { backgroundColor = "#2196F3"
            }
        , textStyle =
            { color = "white"
            , fontWeight = "bold"
            , textAlign = "center"
            }
        , modalText =
            { marginBottom = 15
            , textAlign = "center"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.centeredView ]
        [ modal
            [ animationType "slide"
            , transparent True
            , visible model.modalOpen
            , onRequestClose (Decode.succeed ModalClosing)
            ]
            [ view
                [ style styles.centeredView ]
                [ view
                    [ style styles.modalView ]
                    [ text [ style styles.modalText ] [ str "Hello World!" ]
                    , pressable
                        [ style styles.button
                        , style styles.buttonClose
                        , onPress (Decode.succeed CloseModal)
                        ]
                        [ text [ style styles.textStyle ] [ str "Hide Modal" ] ]
                    ]
                ]
            ]
        , pressable
            [ style styles.button
            , style styles.buttonOpen
            , onPress (Decode.succeed ShowModal)
            ]
            [ text [ style styles.textStyle ] [ str "Show Modal" ] ]
        ]


subs _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
