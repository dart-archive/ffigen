// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('typedef_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'Bindings'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/typedef.h'
  ${strings.includeDirectives}:
    - '**typedef.h'
${strings.structs}:
  ${strings.exclude}:
    - ExcludedStruct
    - _ExcludedStruct
${strings.typedefmap}:
  'SpecifiedTypeAsIntPtr': 'IntPtr'

${strings.preamble}: |
  // ignore_for_file: unused_element, unused_field
        ''') as yaml.YamlMap),
      );
    });

    test('Expected Bindings', () {
      matchLibraryWithExpected(actual, [
        'test',
        'debug_generated',
        'header_parser_typedef_test_output.dart'
      ], [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_typedef_bindings.dart'
      ]);
    });
  });
}
