module PressableExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import ReactNative
    exposing
        ( pressable
        , str
        , text
        , touchableHighlight
        , touchableNativeFeedback
        , touchableOpacity
        , touchableWithoutFeedback
        , view
        )
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (activeOpacity, style, underlayColor)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { count : Int }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { count = 0 }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | Increment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )



-- VIEW


styles =
    StyleSheet.create
        { container =
            { flex = 1
            , justifyContent = "center"
            , paddingHorizontal = 10
            , gap = 10
            }
        , button =
            { alignItems = "center"
            , padding = 10
            , marginVertical = 5
            , backgroundColor = "#DDDDDD"
            }
        , countContainer =
            { alignItems = "center"
            , padding = 10
            }
        , countText =
            { color = "#FF00FF"
            }
        }


root : Model -> Html Msg
root model =
    view [ style styles.container ]
        [ touchableHighlight
            [ onPress <| Decode.succeed Increment ]
            [ view
                [ style styles.button
                , underlayColor "red"
                , activeOpacity 0.5
                ]
                [ text [] [ str "TouchableHighlight" ] ]
            ]
        , touchableOpacity
            [ onPress <| Decode.succeed Increment ]
            [ view
                [ style styles.button ]
                [ text [] [ str "TouchableOpacity" ] ]
            ]
        , touchableWithoutFeedback
            [ onPress <| Decode.succeed Increment ]
            [ view
                [ style styles.button ]
                [ text [] [ str "TouchableWithoutFeedback" ] ]
            ]
        , touchableNativeFeedback
            [ onPress <| Decode.succeed Increment ]
            [ view
                [ style styles.button ]
                [ text [] [ str "TouchableNativeFeedback" ] ]
            ]
        , pressable
            [ onPress <| Decode.succeed Increment
            , style styles.button
            , style
                (\{ pressed } ->
                    if pressed then
                        { backgroundColor = "rgb(210, 230, 255)" }

                    else
                        { backgroundColor = "#DDDDDD" }
                )
            ]
            (\{ pressed } ->
                [ text
                    [ style
                        (if pressed then
                            { color = "red" }

                         else
                            { color = "black" }
                        )
                    ]
                    [ str "Pressable" ]
                ]
            )
        , view [ style styles.countContainer ]
            [ text [ style styles.countText ]
                [ str <| String.fromInt model.count ]
            ]
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
