import registerRootComponent from "expo/build/launch/registerRootComponent";

import Ionicons from "@expo/vector-icons/Ionicons";
import MaterialIcons from "@expo/vector-icons/MaterialIcons";

import App from "./App";
registerRootComponent(() => (
  <App
    resolveComponent={(tag) => {
      if (tag === "Ionicons") return Ionicons;
      else if (tag === "MaterialIcons") return MaterialIcons;
    }}
  />
));
