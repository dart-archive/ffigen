// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('imported_types_test', () {
    setUpAll(() {
      logWarnings();
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Imported types test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/imported_types.h'
  ${strings.includeDirectives}:
    - '**imported_types.h'

${strings.preamble}: |
  // ignore_for_file: camel_case_types
        '''),
      );
    });
    test('Expected Bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_imported_types_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_imported_types_bindings.dart'
      ]);
    });
  });
}
