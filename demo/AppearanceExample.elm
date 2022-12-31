module AppearanceExample exposing (..)

import Browser
import Html exposing (Html)
import Json.Encode as Encode
import ReactNative exposing (str, text, view)
import ReactNative.Appearance as Appearance exposing (ColorScheme(..))
import ReactNative.Properties exposing (style)
import Task exposing (Task)



-- MODEL


type alias Model =
    { colorScheme : ColorScheme }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { colorScheme = NotIndicated }, Task.perform ColorSchemeChanged Appearance.getColorScheme )



-- UPDATE


type Msg
    = NoOp
    | ColorSchemeChanged ColorScheme


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ColorSchemeChanged colorScheme ->
            ( { model | colorScheme = colorScheme }, Cmd.none )



-- VIEW


root : Model -> Html Msg
root model =
    view [ style { flex = 1, alignItems = "center", justifyContent = "center" } ]
        [ text []
            [ str "current color scheme: "
            , str <| Encode.encode 0 <| Appearance.encodeColorScheme model.colorScheme
            ]
        ]


subs _ =
    Appearance.onChange ColorSchemeChanged


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = subs
        }
