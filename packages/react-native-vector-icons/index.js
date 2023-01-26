import Ionicons from "react-native-vector-icons/Ionicons";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";

export default (tag) => {
  if (tag === "Ionicons") return Ionicons;
  if (tag === "MaterialIcons") return MaterialIcons;
};
