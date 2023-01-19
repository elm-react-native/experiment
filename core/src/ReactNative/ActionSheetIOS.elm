module ReactNative.ActionSheetIOS exposing
    ( Property
    , anchor
    , cancelButtonIndex
    , cancelButtonTintColor
    , destructiveButtonIndex
    , destructiveButtonIndices
    , disabledButtonIndices
    , message
    , pickAction
    , show
    , tintColor
    , title
    , userInterfaceStyle
    )

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import ReactNative.Properties exposing (encode)
import Task exposing (Task)


show : List String -> List Property -> Task Never Int
show options props =
    Task.succeed 0


pickAction : List ( String, msg ) -> List Property -> Task Never (Maybe msg)
pickAction items props =
    show (List.map Tuple.first items) props
        |> Task.map
            (\i ->
                case memberAt i items of
                    Just ( _, m ) ->
                        Just m

                    _ ->
                        Nothing
            )


memberAt : Int -> List a -> Maybe a
memberAt i xs =
    case xs of
        x :: xs2 ->
            if i == 0 then
                Just x

            else
                memberAt (i - 1) xs2

        _ ->
            Nothing


type alias Property =
    ( String, Value )


property : String -> Value -> Property
property name value =
    ( name, value )


cancelButtonIndex =
    property "cancelButtonIndex" << Encode.int


cancelButtonTintColor =
    property "cancelButtonTintColor" << Encode.string


destructiveButtonIndex =
    property "destructiveButtonIndex" << Encode.int


destructiveButtonIndices : List Int -> Property
destructiveButtonIndices =
    property "destructiveButtonIndex" << Encode.list Encode.int


title =
    property "title" << Encode.string


message =
    property "message" << Encode.string


anchor =
    property "anchor" << Encode.int


tintColor =
    property "tintColor" << Encode.string


disabledButtonIndices : List Int -> Property
disabledButtonIndices =
    property "disabledButtonIndices" << encode


userInterfaceStyle =
    property "userInterfaceStyle" << Encode.string
