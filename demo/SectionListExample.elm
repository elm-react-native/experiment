module SectionListExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (null, safeAreaView, str, text, view)
import ReactNative.Properties exposing (stickySectionHeadersEnabled, style)
import ReactNative.SectionList exposing (sectionList)
import ReactNative.StatusBar as StatusBar
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    List Section


type alias Section =
    { title : String, data : List String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( [ { title = "Main dishes"
        , data = [ "Pizza", "Burger", "Risotto" ]
        }
      , { title = "Sides"
        , data = [ "French Fries", "Onion Rings", "Fried Shrimps" ]
        }
      , { title = "Drinks"
        , data = [ "Water", "Coke", "Beer" ]
        }
      , { title = "Desserts"
        , data = [ "Cheese Cake", "Ice Cream" ]
        }
      ]
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , paddingTop = StatusBar.currentHeight
            , marginHorizontal = 16
            }
        , item =
            { backgroundColor = "#f9c2ff"
            , padding = 20
            , marginVertical = 8
            }
        , header =
            { fontSize = 32
            , backgroundColor = "#fff"
            }
        , title =
            { fontSize = 24
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.container ]
        [ sectionList
            { sections = model
            , keyExtractor = \item index -> item ++ String.fromInt index
            , renderItem =
                \{ item } ->
                    view [ style styles.item ]
                        [ text [ style styles.title ] [ str item ] ]
            , renderSectionHeader =
                \{ section } ->
                    text [ style styles.header ]
                        [ str section.title ]
            , renderSectionFooter = \_ -> null
            }
            [ stickySectionHeadersEnabled False ]
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
