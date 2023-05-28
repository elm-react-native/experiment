module ReactNative.ContextMenuIOS exposing (MenuItem, MenuItemAttribute(..), contextMenuButton, enableContextMenu, isMenuPrimaryAction, menuConfig, menuItemDecoder, onPressMenuItem, pressEventMenuItemDecoder, useActionSheetFallback)

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


type MenuItemAttribute
    = Disabled
    | Hidden
    | Destructive
    | KeepsMenuPresented


type alias MenuItem =
    { actionKey : String, actionTitle : String, attributes : Maybe (List MenuItemAttribute) }


menuItemAttributeEncoder : MenuItemAttribute -> Encode.Value
menuItemAttributeEncoder attr =
    case attr of
        Disabled ->
            Encode.string "disabled"

        Hidden ->
            Encode.string "hidden"

        Destructive ->
            Encode.string "destructive"

        KeepsMenuPresented ->
            Encode.string "keepsMenuPresented"


menuItemAttributeDecoder : Decoder (Maybe MenuItemAttribute)
menuItemAttributeDecoder =
    let
        fromStr attr =
            case attr of
                "disabled" ->
                    Just Disabled

                "hidden" ->
                    Just Hidden

                "destructive" ->
                    Just Destructive

                "keepsMenuPresented" ->
                    Just KeepsMenuPresented

                _ ->
                    Nothing
    in
    Decode.map fromStr Decode.string


listOfMaybe : Decoder (Maybe a) -> Decoder (List a)
listOfMaybe =
    Decode.map (List.filterMap identity) << Decode.list


menuItemDecoder : Decoder MenuItem
menuItemDecoder =
    Decode.map3 MenuItem
        (Decode.field "actionKey" Decode.string)
        (Decode.field "actionTitle" Decode.string)
        (Decode.maybe <| Decode.field "menuAttributes" (listOfMaybe menuItemAttributeDecoder))


pressEventMenuItemDecoder : Decoder MenuItem
pressEventMenuItemDecoder =
    Decode.field "nativeEvent" menuItemDecoder


menuConfig : { c | menuTitle : String, menuItems : List MenuItem } -> Attribute msg
menuConfig cfg =
    property "menuConfig" <|
        Encode.object
            [ ( "menuTitle", Encode.string cfg.menuTitle )
            , ( "menuItems"
              , Encode.list
                    (\item ->
                        Encode.object
                            [ ( "actionKey", Encode.string item.actionKey )
                            , ( "actionTitle", Encode.string item.actionTitle )
                            , ( "menuAttributes"
                              , case item.attributes of
                                    Just attrs ->
                                        Encode.list menuItemAttributeEncoder attrs

                                    _ ->
                                        Encode.null
                              )
                            ]
                    )
                    cfg.menuItems
              )
            ]


isMenuPrimaryAction =
    property "isMenuPrimaryAction" << Encode.bool


enableContextMenu =
    property "enableContextMenu" << Encode.bool


useActionSheetFallback =
    property "useActionSheetFallback" << Encode.bool
