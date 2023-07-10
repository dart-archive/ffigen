// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ================== GENERATING JSON SCHEMA =====================
//    cd to project's root, and run -
//    dart generate_json_schema.dart
// ===============================================================
import 'dart:convert';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/strings.dart' as strings;

void main() async {
  final actualJsonSchema =
      JsonEncoder.withIndent(strings.ffigenJsonSchemaIndent).convert(
    Config.getsRootConfigSpec().generateJsonSchema(strings.ffigenJsonSchemaId),
  );

  final file = File(strings.ffigenJsonSchemaFileName);
  if (!await file.exists()) {
    throw Exception("File '${file.absolute.path}' does not exist.");
  }
  await file.writeAsString(actualJsonSchema);

  print("Generated json schema: ${file.absolute.path}");
}
