module ContextMenu exposing (MenuItem, contextMenuButton, enableContextMenu, isMenuPrimaryAction, menuConfig, menuItemDecoder, onPressMenuItem, pressEventMenuItemDecoder, useActionSheetFallback)

import Browser
import Html exposing (Attribute, Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import ReactNative exposing (node)
import ReactNative.Events exposing (on)
import ReactNative.Properties exposing (encode, property)


contextMenuButton =
    node "ContextMenuButton"


onPressMenuItem =
    on "pressMenuItem"


type alias MenuItem =
    { actionKey : String, actionTitle : String }


menuItemDecoder : Decoder MenuItem
menuItemDecoder =
    Decode.map2 MenuItem
        (Decode.field "actionKey" Decode.string)
        (Decode.field "actionTitle" Decode.string)


pressEventMenuItemDecoder : Decoder MenuItem
pressEventMenuItemDecoder =
    Decode.field "nativeEvent" menuItemDecoder


menuConfig : { c | menuTitle : String, menuItems : List MenuItem } -> Attribute msg
menuConfig cfg =
    property "menuConfig" <|
        Encode.object
            [ ( "menuTitle", Encode.string cfg.menuTitle )
            , ( "menuItems", Encode.list encode cfg.menuItems )
            ]


isMenuPrimaryAction =
    property "isMenuPrimaryAction" << Encode.bool


enableContextMenu =
    property "enableContextMenu" << Encode.bool


useActionSheetFallback =
    property "useActionSheetFallback" << Encode.bool
