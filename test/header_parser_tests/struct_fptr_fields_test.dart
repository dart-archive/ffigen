// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
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

late Library actual;
void main() {
  group('Function pointer parameters parsing test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Function pointer fields in structs Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/struct_fptr_fields.h'
        ''') as yaml.YamlMap),
      );
    });

    test('Expected bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_struct_fptr_fields_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_struct_fptr_fields_bindings.dart',
      ]);
    });
  });
}
