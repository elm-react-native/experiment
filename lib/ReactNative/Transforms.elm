module ReactNative.Transforms exposing
    ( Transform
    , matrix
    , perspective
    , rotate
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

import Html exposing (Attribute)
import Json.Encode as Encode
import ReactNative.Properties exposing (style)


{-| Transforms are style properties that will help you modify the appearance and position of your components using 2D or 3D transformations.
However, once you apply transforms, the layouts remain the same around the transformed component hence it might overlap with the nearby components.
You can apply margin to the transformed component, the nearby components or padding to the container to prevent such overlaps.
-}
type Transform
    = Transform (List ( String, Encode.Value ))


transform : List Transform -> Attribute msg
transform trans =
    style
        { transform =
            Encode.list (\(Transform fs) -> Encode.object fs) trans
        }


matrix : List Float -> Transform
matrix val =
    Transform [ ( "matrix", Encode.list Encode.float val ) ]


perspective : Float -> Transform
perspective val =
    Transform [ ( "perspective", Encode.float val ) ]


rotate : String -> Transform
rotate val =
    Transform [ ( "rotate", Encode.string val ) ]


rotateX : String -> Transform
rotateX val =
    Transform [ ( "rotateX", Encode.string val ) ]


rotateY : String -> Transform
rotateY val =
    Transform [ ( "rotateY", Encode.string val ) ]


rotateZ : String -> Transform
rotateZ val =
    Transform [ ( "rotateZ", Encode.string val ) ]


scale : Float -> Transform
scale val =
    Transform [ ( "scale", Encode.float val ) ]


scaleX : Float -> Transform
scaleX val =
    Transform [ ( "scaleX", Encode.float val ) ]


scaleY : Float -> Transform
scaleY val =
    Transform [ ( "scaleY", Encode.float val ) ]


translateX : Float -> Transform
translateX val =
    Transform [ ( "translateX", Encode.float val ) ]


translateY : Float -> Transform
translateY val =
    Transform [ ( "translateY", Encode.float val ) ]


skewX : String -> Transform
skewX val =
    Transform [ ( "skewX", Encode.string val ) ]


skewY : String -> Transform
skewY val =
    Transform [ ( "skewY", Encode.string val ) ]
