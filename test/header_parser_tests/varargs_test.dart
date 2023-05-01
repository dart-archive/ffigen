// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
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
  group('varargs_test', () {
    setUpAll(() {
      logWarnings();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'VarArgs Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/varargs.h'

${strings.functions}:
  ${strings.varArgFunctions}:
    myfunc:
      - [int, char*, SA]
    myfunc2:
      - [char*, long**]
      - [SA, int*, unsigned char**]
      - types: [SA, int*, unsigned char**]
        postfix: _custompostfix
    myfunc3:
      - [Struct_WithLong_Name_test*, float*]
      - types: [Struct_WithLong_Name_test]
        postfix: _custompostfix2

${strings.preamble}: |
  // ignore_for_file: camel_case_types
        ''') as yaml.YamlMap),
      );
    });
    test('Expected Bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_varargs_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_varargs_bindings.dart'
      ]);
    });
  });
}
