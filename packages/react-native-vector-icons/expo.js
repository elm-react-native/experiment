import React from "react";
import { Platform, Text } from "react-native";

let Ionicons;
let MaterialIcons;

const isIOS26OrNewer =
  Platform.OS === "ios" && Number.parseInt(`${Platform.Version}`, 10) >= 26;

const fallbackGlyphs = {
  "ios-information-circle": "i",
  "ios-list": "=",
  "keyboard-arrow-right": ">",
};

const fallbackIcon =
  () =>
  ({ color, name, size = 24, style }) =>
    (
      <Text
        style={[
          {
            color,
            fontSize: size,
            lineHeight: size,
            textAlign: "center",
            width: size,
          },
          style,
        ]}
      >
        {fallbackGlyphs[name] || ""}
      </Text>
    );

const loadExpoIcons = () => {
  Ionicons ||= require("@expo/vector-icons/Ionicons").default;
  MaterialIcons ||= require("@expo/vector-icons/MaterialIcons").default;
};

export default (tag) => {
  if (isIOS26OrNewer) return fallbackIcon();

  loadExpoIcons();

  if (tag === "Ionicons") return Ionicons;
  else if (tag === "MaterialIcons") return MaterialIcons;
};
