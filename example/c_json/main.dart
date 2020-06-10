import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'cjson_generated_bindings.dart' as cjson;

// TODO: remove this when tool can parse struct fields
class cJSON extends Struct {
  Pointer<cJSON> next, prev, child;

  @Int32()
  int type;

  Pointer<Utf8> valueString;
  @Int32()
  int valueInt;
  @Double()
  double valuedouble;

  Pointer<Utf8> string;

  cJSON._();
}

/// Using the generated C_JSON bindings
void main() {
  //init cjson bindings
  cjson.init(DynamicLibrary.open(_getPath()));

  // load json from [example.json] file
  var jsonString = File('./example.json').readAsStringSync();

  // parse this json string using our cJSON library
  var cjsonParsedJson = cjson.cJSON_Parse(Utf8.toUtf8(jsonString).cast());
  if (cjsonParsedJson == null) {
    print('Error parsing cjson');
    exit(1);
  }

  // the json is now stored in some C data structure which we need
  // to iterate and convert to a dart object (map/list)
  dynamic dartJson = convertCJsonToDartObj(cjsonParsedJson.cast());

  // delete the cjsonParsedJson object
  cjson.cJSON_Delete(cjsonParsedJson);

  // check if the converted json is correct
  // by comparing the result with json converted by dart:convert
  if (dartJson.toString() == json.decode(jsonString).toString()) {
    print('Json converted successfully');
  } else {
    print("Converted json doesn't match\n");
    print('Actual:\n' + dartJson.toString() + '\n');
    print('Expected:\n' + json.decode(jsonString).toString());
  }
}

String _getPath() {
  var path = './cjson_library/libcjson.so';
  if (Platform.isMacOS) path = './cjson_library/libstructs.dylib';
  if (Platform.isWindows) path = r'cjson_library\Debug\structs.dll';
  return path;
}

dynamic convertCJsonToDartObj(Pointer<cJSON> parsedcjson) {
  dynamic obj;
  if (cjson.cJSON_IsObject(parsedcjson.cast()) == 1) {
    obj = <String, dynamic>{};

    Pointer<cJSON> ptr;
    ptr = parsedcjson.ref.child;
    while (ptr != nullptr) {
      dynamic o = convertCJsonToDartObj(ptr);
      _addToObj(obj, o, ptr.ref.string);
      ptr = ptr.ref.next;
    }
  } else if (cjson.cJSON_IsArray(parsedcjson.cast()) == 1) {
    obj = <dynamic>[];

    Pointer<cJSON> ptr;
    ptr = parsedcjson.ref.child;
    while (ptr != nullptr) {
      dynamic o = convertCJsonToDartObj(ptr);
      _addToObj(obj, o);
      ptr = ptr.ref.next;
    }
  } else if (cjson.cJSON_IsString(parsedcjson.cast()) == 1) {
    obj = Utf8.fromUtf8(parsedcjson.ref.valueString);
  } else if (cjson.cJSON_IsNumber(parsedcjson.cast()) == 1) {
    obj = parsedcjson.ref.valueInt == parsedcjson.ref.valuedouble
        ? parsedcjson.ref.valueInt
        : parsedcjson.ref.valuedouble;
  }

  return obj;
}

void _addToObj(dynamic obj, dynamic o, [Pointer<Utf8> name]) {
  if (obj is Map<String, dynamic>) {
    obj[Utf8.fromUtf8(name)] = o;
  } else if (obj is List<dynamic>) {
    obj.add(o);
  }
}