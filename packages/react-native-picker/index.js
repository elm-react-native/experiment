import { Picker, PickerIOS } from "@react-native-picker/picker";

export default resolveComponent = (tag) => {
  if (tag === "Picker") return [Picker, Picker.Item];
};
