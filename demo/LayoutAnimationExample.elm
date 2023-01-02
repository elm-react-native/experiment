module LayoutAnimationExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative exposing (button, fragment, scrollView, str, text, touchableOpacity, view)
import ReactNative.Events exposing (onPress)
import ReactNative.LayoutAnimation as LayoutAnimation
import ReactNative.Properties exposing (contentContainerStyle, style, title)
import ReactNative.StyleSheet as StyleSheet
import Task exposing (Task)



-- MODEL


type alias Model =
    { expanded : Bool
    , boxes : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { expanded = False, boxes = [ "left", "left", "left", "left" ] }, Cmd.none )


type alias Box =
    { label : String
    , config : LayoutAnimation.Config
    }


configs : List Box
configs =
    [ { label = "EaseInEaseOut", config = LayoutAnimation.easeInEaseOut }
    , { label = "Linear", config = LayoutAnimation.linear }
    , { label = "Spring", config = LayoutAnimation.spring }
    , { label = "Custom"
      , config =
            LayoutAnimation.config
                { duration = 500
                , create = ( "linear", { property = "opacity" } )
                , update = ( "spring", { springDamping = 0.4 } )
                , delete = ( "linear", { property = "opacity" } )
                }
      }
    ]



-- UPDATE


type Msg
    = NoOp
    | ToggleExpanded
    | ToggleBoxPosition Int LayoutAnimation.Config


togglePosition box =
    if box == "left" then
        "right"

    else
        "left"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleExpanded ->
            ( { model | expanded = not model.expanded }
            , Task.attempt (always NoOp) <| LayoutAnimation.configureNext LayoutAnimation.spring
            )

        ToggleBoxPosition i cfg ->
            ( { model | boxes = updateAt i togglePosition model.boxes }
            , cfg
                |> LayoutAnimation.configureNext
                |> Task.attempt (always NoOp)
            )



-- VIEW


styles =
    StyleSheet.create
        { title =
            { backgroundColor = "lightgrey"
            , borderWidth = 0.5
            , borderColor = "#d6d7da"
            }
        , container =
            { flex = 1
            , alignItems = "flex-start"
            , justifyContent = "center"
            }
        , box =
            { height = 50
            , width = 50
            , borderRadius = 5
            , margin = 8
            , backgroundColor = "blue"
            }
        , moveLeft = {}
        , moveRight =
            { alignSelf = "flex-end"
            , height = 100
            , width = 100
            }
        , buttonContainer =
            { alignSelf = "left"
            }
        }


boxView pos =
    view
        [ if pos == "left" then
            style styles.box

          else
            style <| StyleSheet.compose styles.box styles.moveRight
        ]
        []


boxesView boxes =
    boxes
        |> zip configs
        |> List.indexedMap
            (\i ( { label, config }, pos ) ->
                [ view
                    [ style styles.buttonContainer ]
                    [ button
                        [ title label
                        , onPress <| Decode.succeed <| ToggleBoxPosition i config
                        ]
                        []
                    ]
                , boxView pos
                ]
            )
        |> List.concat


collapsableView expanded =
    [ touchableOpacity [ onPress <| Decode.succeed ToggleExpanded ]
        [ text []
            [ str <|
                "Press me to "
                    ++ (if expanded then
                            "collapse"

                        else
                            "expand"
                       )
                    ++ "!"
            ]
        ]
    ]
        ++ (if expanded then
                [ view
                    [ style styles.title ]
                    [ text [] [ str "I disappear sometimes!" ] ]
                ]

            else
                []
           )


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        (boxesView model.boxes
            ++ collapsableView model.expanded
        )


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



-- LIST helpers


updateAt : Int -> (a -> a) -> List a -> List a
updateAt n fn xs =
    case xs of
        x :: rest ->
            if n == 0 then
                fn x :: rest

            else if n < 0 then
                xs

            else
                x :: updateAt (n - 1) fn rest

        _ ->
            xs


zip : List a -> List b -> List ( a, b )
zip a b =
    List.map2 Tuple.pair a b
