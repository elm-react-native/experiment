module FlatListExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (flatList, safeAreaView, str, text, touchableOpacity)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (style)
import ReactNative.StatusBar as StatusBar
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Item =
    { id : String, title : String }


type alias Model =
    { selectedId : Maybe String
    , list : List Item
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selectedId = Nothing
      , list =
            [ { id = "bd7acbea-c1b1-46c2-aed5-3ad53abb28ba"
              , title = "First Item"
              }
            , { id = "3ac68afc-c605-48d3-a4f8-fbd91aa97f63"
              , title = "Second Item"
              }
            , { id = "58694a0f-3da1-471f-bd96-145571e29d72"
              , title = "Third Item"
              }
            ]
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | Select String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Select id ->
            ( { model | selectedId = Just id }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , marginTop = StatusBar.currentHeight
            }
        , item =
            { padding = 20
            , marginVertical = 8
            , marginHorizontal = 16
            }
        , title =
            { fontSize = 32
            }
        }


listItem : Item -> Bool -> Html Msg
listItem item isSelected =
    let
        ( backgroundColor, textColor ) =
            if isSelected then
                ( "#6e3b6e", "white" )

            else
                ( "#f9c2ff", "black" )
    in
    touchableOpacity
        [ style styles.item
        , style
            { backgroundColor = backgroundColor
            }
        , onPress <| Decode.succeed (Select item.id)
        ]
        [ text
            [ style styles.title
            , style { color = textColor }
            ]
            [ str item.title ]
        ]


root : Model -> Html Msg
root model =
    safeAreaView
        [ style styles.container ]
        [ flatList
            { data = model.list
            , keyExtractor = \item _ -> item.id
            , renderItem =
                \{ item } ->
                    listItem item <|
                        case model.selectedId of
                            Just selectedId ->
                                item.id == selectedId

                            _ ->
                                False
            , getItemLayout = Nothing
            }
            []
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
