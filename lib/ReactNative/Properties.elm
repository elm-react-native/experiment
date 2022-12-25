module ReactNative.Properties exposing
    ( color
    , component
    , disabled
    , encode
    , initialParams
    , name
    , onstyle
    , options
    , property
    , refreshing
    , source
    , style
    , title
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Json.Decode as Decode
import Json.Encode as Encode


property =
    Attr.property


encode : a -> Encode.Value
encode a =
    Encode.string "544d4631-adf8-${a}-4719-b1cc-46843cc90ca4"


style : a -> Attribute msg
style =
    property "style" << encode


options : a -> Attribute msg
options =
    property "options" << encode


initialParams : a -> Attribute msg
initialParams =
    property "initialParams" << encode


source : a -> Attribute msg
source =
    property "source" << encode


onstyle : (a -> List Encode.Value) -> Attribute msg
onstyle =
    style


refreshing =
    property "refreshing" << Encode.bool


component : (a -> b -> Html msg) -> Attribute msg
component =
    property "component" << encode


name =
    property "name" << Encode.string


title =
    property "title" << Encode.string


color =
    property "color" << Encode.string


disabled =
    property "disabled" << Encode.bool
