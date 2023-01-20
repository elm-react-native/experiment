module PickerExample exposing (..)

import Browser
import Html exposing (Html)
import Picker exposing (itemStyle, label, numberOfLines, onValueChange, picker, pickerItem, selectedValue)
import ReactNative exposing (null, str, text, view)
import ReactNative.Events exposing (onStringValueChange)
import ReactNative.Properties exposing (stringValue, style)
import ReactNative.StyleSheet as StyleSheet



-- MODEL


type alias Model =
    { selectedValue : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selectedValue = "" }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | Select String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Select value ->
            let
                _ =
                    Debug.log "select value" value
            in
            ( { model | selectedValue = value }, Cmd.none )



-- VIEW


root : Model -> Html Msg
root model =
    view [ style { alignItems = "center", justifyContent = "center", height = "100%", width = "100%" } ]
        [ picker
            [ selectedValue model.selectedValue
            , itemStyle { color = "red" }
            , onValueChange (\{ item } -> Select item)
            , style { width = "100%", backgroundColor = "white", borderRadius = 8 }
            ]
            (List.range 0 5
                |> List.map
                    (\i ->
                        let
                            s =
                                String.fromInt i
                        in
                        pickerItem [ label <| "Item " ++ s, stringValue <| "item" ++ s ] []
                    )
            )
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = root
        , update = update
        , subscriptions = \_ -> Sub.none
        }
