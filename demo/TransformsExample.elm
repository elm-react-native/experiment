module TransformsExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (safeAreaView, scrollView, text, view)
import ReactNative.Properties exposing (contentContainerStyle, style)
import ReactNative.StyleSheet as StyleSheet
import ReactNative.Transforms
    exposing
        ( rotate
        , rotateX
        , rotateY
        , rotateZ
        , scale
        , scaleX
        , scaleY
        , skewX
        , skewY
        , transform
        , translateX
        , translateY
        )



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



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
            }
        , scrollContentContainer =
            { alignItems = "center"
            , paddingBottom = 60
            }
        , box =
            { height = 100
            , width = 100
            , borderRadius = 5
            , marginVertical = 40
            , backgroundColor = "#61dafb"
            , alignItems = "center"
            , justifyContent = "center"
            }
        , text =
            { fontSize = 14
            , fontWeight = "bold"
            , margin = 8
            , color = "#000"
            , textAlign = "center"
            }
        }


root : Model -> Html Msg
root model =
    safeAreaView [ style styles.container ]
        [ scrollView [ contentContainerStyle styles.scrollContentContainer ]
            [ view
                [ style styles.box ]
                [ text [ style styles.text ] "Original Object" ]
            , view
                [ style styles.box, transform [ scale 2 ] ]
                [ text [ style styles.text ] "Scale by 2" ]
            , view
                [ style styles.box, transform [ scaleX 2 ] ]
                [ text [ style styles.text ] "ScaleX by 2" ]
            , view
                [ style styles.box, transform [ scaleY 2 ] ]
                [ text [ style styles.text ] "ScaleY by 2" ]
            , view
                [ style styles.box, transform [ rotate "45deg" ] ]
                [ text [ style styles.text ] "Rotate by 45 deg" ]
            , view
                [ style styles.box, transform [ rotateX "45deg", rotateZ "45deg" ] ]
                [ text [ style styles.text ] "RotateX&Z by 45 deg" ]
            , view
                [ style styles.box, transform [ rotateY "45deg", rotateZ "45deg" ] ]
                [ text [ style styles.text ] "RotateY&Z by 45 deg" ]
            , view
                [ style styles.box, transform [ skewX "45deg" ] ]
                [ text [ style styles.text ] "SkewX by 45 deg" ]
            , view
                [ style styles.box, transform [ skewY "45deg" ] ]
                [ text [ style styles.text ] "SkewY by 45 deg" ]
            , view
                [ style styles.box, transform [ skewX "30deg", skewY "30deg" ] ]
                [ text [ style styles.text ] "SkewX&Y by 30 deg" ]
            , view
                [ style styles.box, transform [ translateX -50 ] ]
                [ text [ style styles.text ] "TranslateX by -50" ]
            , view
                [ style styles.box, transform [ translateY 50 ] ]
                [ text [ style styles.text ] "TranslateY by 50" ]
            ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
