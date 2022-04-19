// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

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
  group('objc_config_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'ObjC Config Test'
${strings.output}: 'unused'
${strings.language}: '${strings.langObjC}'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/objc_config.h'
${strings.objcInterfaces}:
  ${strings.include}:
    - 'Foo'
  ${strings.exclude}:
    - 'Excluded'
  ${strings.rename}:
    '_(.*)': '\$1'
''') as yaml.YamlMap),
      );
    });
    test('Expected bindings', () {
      matchLibraryWithExpected(actual, [
        'test',
        'debug_generated',
        'header_parser_objc_config_test_output.dart'
      ], [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_objc_config_bindings.dart'
      ]);
    });
  });
}
