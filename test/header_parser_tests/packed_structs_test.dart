// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual;
void main() {
  group('packed_structs_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Packed Structs Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/packed_structs.h'
        '''),
      );
    });

    test('Expected bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_packed_structs_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_packed_structs_bindings.dart'
      ]);
    });
  });
}
