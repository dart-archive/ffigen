// Macro constants are not parsed by this this tool yet
// so we created this file manually
// TODO: remove when support for macro constant arrives

class Types {
  static const cJSON_Invalid = (0);
  static const cJSON_False = (1 << 0);
  static const cJSON_True = (1 << 1);
  static const cJSON_NULL = (1 << 2);
  static const cJSON_Number = (1 << 3);
  static const cJSON_String = (1 << 4);
  static const cJSON_Array = (1 << 5);
  static const cJSON_Object = (1 << 6);
  static const cJSON_Raw = (1 << 7);
}

class Bools {
  static const cJSON_Bool_False = 0;
  static const cJSON_Bool_True = 1;
}
