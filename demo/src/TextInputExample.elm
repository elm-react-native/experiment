module TextInputExample exposing (..)

import Browser
import Html exposing (Html)
import ReactNative exposing (safeAreaView, textInput)
import ReactNative.Events exposing (onChangeText)
import ReactNative.Properties exposing (editable, maxLength, multiline, numberOfLines, stringValue, style)



-- MODEL


type alias Model =
    { value : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { value = "Useless Multiline Placeholder" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | ChangeText String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangeText text ->
            ( { model | value = text }, Cmd.none )



-- VIEW


uselessTextInput props =
    textInput (props ++ [ editable True, maxLength 40 ]) []


root : Model -> Html Msg
root model =
    safeAreaView
        [ style
            { backgroundColor = model.value
            , borderBottomColor = "#000000"
            , borderBottomWidth = 1
            }
        ]
        [ uselessTextInput
            [ multiline True
            , numberOfLines 4
            , onChangeText ChangeText
            , stringValue model.value
            , style { padding = 20 }
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
