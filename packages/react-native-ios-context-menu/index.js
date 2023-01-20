import { ContextMenuButton } from "react-native-ios-context-menu";

export default resolveComponent = (tag) => {
  if (tag === "ContextMenuButton") return ContextMenuButton;
};
