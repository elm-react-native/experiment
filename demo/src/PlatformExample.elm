module PlatformExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import ReactNative exposing (safeAreaView, scrollView, str, text, view)
import ReactNative.Platform as Platform
import ReactNative.Properties exposing (contentContainerStyle, style)
import ReactNative.StyleSheet as StyleSheet



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
            , justifyContent = "center"
            , alignItems = "center"
            }
        , value =
            { fontWeight = "600"
            , padding = 4
            , marginBottom = 8
            }
        }


root : Model -> Html Msg
root model =
    scrollView
        [ contentContainerStyle styles.container ]
        ([ text [] [ str "OS" ]
         , text [ style styles.value ] [ str <| Platform.os ]
         , text [] [ str "OS Version" ]
         , text [ style styles.value ] [ str <| Encode.encode 0 <| Encode.float Platform.version ]
         , text [] [ str "isTV" ]
         , text [ style styles.value ] [ str <| Encode.encode 0 <| Encode.bool Platform.isTV ]
         , text [] [ str "contants" ]
         , text [ style styles.value ] [ str <| Platform.constants ]
         ]
            ++ (if Platform.os == "ios" then
                    [ text [] [ str "isPad" ]
                    , text [ style styles.value ] [ str <| Encode.encode 0 <| Encode.bool Platform.isPad ]
                    ]

                else
                    []
               )
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
