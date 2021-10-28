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
  group('decl_type_name_collision test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Decl type name collision test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/collision_tests/decl_type_name_collision.h'
${strings.preamble}: |
    // ignore_for_file: non_constant_identifier_names, 
        ''') as yaml.YamlMap),
      );
    });

    test('Expected bindings', () {
      matchLibraryWithExpected(actual, [
        'test',
        'debug_generated',
        'decl_type_name_collision_test_output.dart'
      ], [
        'test',
        'collision_tests',
        'expected_bindings',
        '_expected_decl_type_name_collision_bindings.dart'
      ]);
    });
  });
}
