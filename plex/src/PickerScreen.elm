module PickerScreen exposing (pickerScreen)

import Html exposing (Html)
import Json.Decode as Decode
import Model exposing (..)
import Picker exposing (itemStyle, label, onValueChange, picker, pickerItem, selectedValue)
import ReactNative exposing (null, touchableWithoutFeedback, view)
import ReactNative.Events exposing (onPress)
import ReactNative.Properties exposing (stringValue, style, themeVariant)
import ReactNative.StyleSheet as StyleSheet
import Theme
import Utils


pickerScreen : HomeModel -> { items : List ( String, Msg ), selectedIndex : Int } -> Html Msg
pickerScreen _ { items, selectedIndex } =
    let
        ( selectedLabel, selectedItemMsg ) =
            case Utils.elementAt selectedIndex items of
                Just x ->
                    x

                _ ->
                    ( "", NoOp )
    in
    view
        [ style
            { flexDirection = "column"
            , height = "100%"
            }
        ]
        [ touchableWithoutFeedback
            [ onPress <| Decode.succeed selectedItemMsg ]
            [ view [ style { flex = 1 } ] []
            ]
        , picker
            [ onValueChange
                (\{ index } ->
                    case Utils.elementAt index items of
                        Just ( _, msg ) ->
                            msg

                        Nothing ->
                            NoOp
                )
            , selectedValue selectedLabel
            , itemStyle { color = "white" }
            , style
                { backgroundColor = Theme.backgroundColor
                , borderTopColor = Theme.themeColor
                , borderTopWidth = StyleSheet.hairlineWidth * 2
                }
            ]
            (List.map (\( text, _ ) -> pickerItem [ label text, stringValue text ] []) items)
        ]
