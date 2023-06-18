// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

late Library actual, expected;

void main() {
  group('json_schema_test', () {
    test('Schema Changes', () {
      final actualJsonSchema =
          JsonEncoder.withIndent(strings.ffigenJsonSchemaIndent).convert(
        Config.getsRootSchema().generateJsonSchema(strings.ffigenJsonSchemaId),
      );
      final expectedJsonSchema = File(strings.ffigenJsonSchemaFileName)
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(actualJsonSchema, expectedJsonSchema);
    });
  });
}
