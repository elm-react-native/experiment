import { Picker, PickerIOS } from "@react-native-picker/picker";

export default (tag) => {
  if (tag === "Picker") return [Picker, Picker.Item];
};
