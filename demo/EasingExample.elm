module EasingExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (null, safeAreaView, sectionList, statusBar, str, text, touchableOpacity, view)
import ReactNative.Animated as Animated
import ReactNative.Easing as Easing
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (hidden, keyExtractor, renderItem, renderSectionHeader, sections, style)
import ReactNative.StyleSheet as StyleSheet
import Task



-- MODEL


type alias Model =
    List Section


type alias Section =
    { title : String, data : List EasingExample }


type alias EasingExample =
    { title : String, easing : Easing.EasingFunction }


init : () -> ( Model, Cmd Msg )
init _ =
    ( [ { title = "Predefined animations"
        , data =
            [ { title = "Bounce", easing = Easing.bounce }
            , { title = "Ease", easing = Easing.ease }
            , { title = "Elastic", easing = Easing.elastic 4 }
            ]
        }
      , { title = "Standard functions"
        , data =
            [ { title = "Linear", easing = Easing.linear }
            , { title = "Quad", easing = Easing.quad }
            , { title = "Cubic", easing = Easing.cubic }
            ]
        }
      , { title = "Additional functions"
        , data =
            [ { title = "Bezier"
              , easing = Easing.bezier ( 0, 2 ) ( 1, -1 )
              }
            , { title = "Circle", easing = Easing.circle }
            , { title = "Sin", easing = Easing.sin }
            , { title = "Exp", easing = Easing.exp }
            ]
        }
      , { title = "Combinations"
        , data =
            [ { title = "In + Bounce"
              , easing = Easing.in_ Easing.bounce
              }
            , { title = "Out + Exp"
              , easing = Easing.out Easing.exp
              }
            , { title = "InOut + Elastic"
              , easing = Easing.inOut <| Easing.elastic 1
              }
            ]
        }
      ]
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | StartAnimate Easing.EasingFunction


opacity =
    Animated.create 0


size =
    Animated.interpolate
        { inputRange = [ 0, 1 ]
        , outputRange = [ 0, 80 ]
        }
        opacity


animate easing =
    opacity
        |> Animated.setValue 0
        |> Animated.timing
            { toValue = 1
            , duration = 1200
            , easing = easing
            }
        |> Animated.start


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        StartAnimate easing ->
            ( model
            , easing
                |> animate
                |> Task.perform (\_ -> NoOp)
            )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , backgroundColor = "#20232a"
            }
        , title =
            { marginTop = 10
            , textAlign = "center"
            , color = "#61dafb"
            }
        , boxContainer =
            { height = 160
            , alignItems = "center"
            }
        , box =
            { marginTop = 32
            , borderRadius = 4
            , backgroundColor = "#61dafb"
            }
        , list =
            { backgroundColor = "#fff"
            }
        , listHeader =
            { paddingHorizontal = 8
            , paddingVertical = 4
            , backgroundColor = "#f4f4f4"
            , color = "#999"
            , fontSize = 12
            , textTransform = "uppercase"
            }
        , listRow =
            { padding = 8
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.container ]
        [ statusBar [ hidden True ] []
        , text [ style styles.title ] [ str "Press rows below to preview the Easing!" ]
        , view [ style styles.boxContainer ]
            [ Animated.view
                [ style styles.box
                , style { opacity = opacity, width = size, height = size }
                ]
                []
            ]
        , sectionList
            { sections = model
            , keyExtractor = \{ title } _ -> title
            , renderItem =
                \{ item } ->
                    touchableOpacity
                        [ style styles.listRow
                        , onPress <| Decode.succeed <| StartAnimate item.easing
                        ]
                        [ text [] [ str item.title ] ]
            , renderSectionHeader = \{ section } -> text [ style styles.listHeader ] [ str section.title ]
            , renderSectionFooter = \_ -> null
            }
            [ style styles.list ]
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
