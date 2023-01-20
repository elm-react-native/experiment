import Ionicons from "@expo/vector-icons/Ionicons";
import MaterialIcons from "@expo/vector-icons/MaterialIcons";
export default resolveComponent = (tag) => {
  if (tag === "Ionicons") return Ionicons;
  else if (tag === "MaterialIcons") return MaterialIcons;
};
