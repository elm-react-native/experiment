import { registerRootComponent } from "expo";

import vectorIconsResolveComponent from "@elm-react-native/react-native-vector-icons/expo";

import App from "@elm-module/Demo";
registerRootComponent(() => (
  <App
    resolveComponent={(tag) => {
      return vectorIconsResolveComponent(tag);
    }}
  />
));
