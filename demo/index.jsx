import registerRootComponent from "expo/build/launch/registerRootComponent";

import vectorIconsResolveComponent from "@elm-react-native/react-native-vector-icons/expo";

import App from "./App";
registerRootComponent(() => (
  <App
    resolveComponent={(tag) => {
      return vectorIconsResolveComponent(tag);
    }}
  />
));
