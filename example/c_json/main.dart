// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

import 'cjson_generated_bindings.dart' as cj;

final cjson = cj.CJson(DynamicLibrary.open(_getPath()));

/// Using the generated C_JSON bindings.
void main() {
  // Load json from [example.json] file.
  final jsonString = File('./example.json').readAsStringSync();

  // Parse this json string using our cJSON library.
  final cjsonParsedJson = cjson.cJSON_Parse(jsonString.toNativeUtf8().cast());
  if (cjsonParsedJson == nullptr) {
    print('Error parsing cjson.');
    exit(1);
  }
  // The json is now stored in some C data structure which we need
  // to iterate and convert to a dart object (map/list).

  // Converting cjson object to a dart object.
  final dynamic dartJson = convertCJsonToDartObj(cjsonParsedJson.cast());

  // Delete the cjsonParsedJson object.
  cjson.cJSON_Delete(cjsonParsedJson);

  // Check if the converted json is correct
  // by comparing the result with json converted by `dart:convert`.
  if (dartJson.toString() == json.decode(jsonString).toString()) {
    print('Parsed Json: $dartJson');
    print('Json converted successfully');
  } else {
    print("Converted json doesn't match\n");
    print('Actual:\n' + dartJson.toString() + '\n');
    print('Expected:\n' + json.decode(jsonString).toString());
  }
}

String _getPath() {
  final cjsonExamplePath = Directory.current.absolute.path;
  var path = p.join(cjsonExamplePath, '../../third_party/cjson_library/');
  if (Platform.isMacOS) {
    path = p.join(path, 'libcjson.dylib');
  } else if (Platform.isWindows) {
    path = p.join(path, 'Debug', 'cjson.dll');
  } else {
    path = p.join(path, 'libcjson.so');
  }
  return path;
}

dynamic convertCJsonToDartObj(Pointer<cj.cJSON> parsedcjson) {
  dynamic obj;
  if (cjson.cJSON_IsObject(parsedcjson.cast()) == 1) {
    obj = <String, dynamic>{};

    Pointer<cj.cJSON>? ptr;
    ptr = parsedcjson.ref.child;
    while (ptr != nullptr) {
      final dynamic o = convertCJsonToDartObj(ptr!);
      _addToObj(obj, o, ptr.ref.string.cast());
      ptr = ptr.ref.next;
    }
  } else if (cjson.cJSON_IsArray(parsedcjson.cast()) == 1) {
    obj = <dynamic>[];

    Pointer<cj.cJSON>? ptr;
    ptr = parsedcjson.ref.child;
    while (ptr != nullptr) {
      final dynamic o = convertCJsonToDartObj(ptr!);
      _addToObj(obj, o);
      ptr = ptr.ref.next;
    }
  } else if (cjson.cJSON_IsString(parsedcjson.cast()) == 1) {
    obj = parsedcjson.ref.valuestring.cast<Utf8>().toDartString();
  } else if (cjson.cJSON_IsNumber(parsedcjson.cast()) == 1) {
    obj = parsedcjson.ref.valueint == parsedcjson.ref.valuedouble
        ? parsedcjson.ref.valueint
        : parsedcjson.ref.valuedouble;
  }

  return obj;
}

void _addToObj(dynamic obj, dynamic o, [Pointer<Utf8>? name]) {
  if (obj is Map<String, dynamic>) {
    obj[name!.toDartString()] = o;
  } else if (obj is List<dynamic>) {
    obj.add(o);
  }
}
