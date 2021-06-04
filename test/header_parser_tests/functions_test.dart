// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('functions_test', () {
    setUpAll(() {
      logWarnings();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Functions Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/functions.h'
  ${strings.includeDirectives}:
    - '**functions.h'

${strings.functions}:
  ${strings.symbolAddress}:
    ${strings.include}:
      - func3
      - func4

${strings.preamble}: |
  // ignore_for_file: camel_case_types
        ''') as yaml.YamlMap),
      );
    });
    test('Expected Bindings', () {
      matchLibraryWithExpected(actual, [
        'test',
        'debug_generated',
        'header_parser_functions_test_output.dart'
      ], [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_functions_bindings.dart'
      ]);
    });
  });
}
