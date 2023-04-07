// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
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
  group('regress_384_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Regression test for #384'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/regress_384_header_1.h'
    - 'test/header_parser_tests/regress_384_header_2.h'
        '''),
      );
    });

    test('Expected bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_regress_384_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_regress_384_bindings.dart'
      ]);
    });
  });
}
