module ReactNative.Properties exposing
    ( color
    , component
    , disabled
    , name
    , onstyle
    , options
    , property
    , record
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


record : a -> Encode.Value
record a =
    Encode.string "544d4631-adf8-${a}-4719-b1cc-46843cc90ca4"


style : a -> Attribute msg
style =
    property "style" << record


options : a -> Attribute msg
options =
    property "options" << record


source : a -> Attribute msg
source =
    property "source" << record


onstyle : (a -> List Encode.Value) -> Attribute msg
onstyle =
    style


refreshing =
    property "refreshing" << Encode.bool


component : (a -> Html msg) -> Attribute msg
component =
    property "component" << record


name =
    property "name" << Encode.string


title =
    property "title" << Encode.string


color =
    property "color" << Encode.string


disabled =
    property "disabled" << Encode.bool
