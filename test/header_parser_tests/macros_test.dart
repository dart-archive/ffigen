// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/config_provider.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:ffigen/src/strings.dart' as strings;

import '../test_utils.dart';

Library actual, expected;

void main() {
  group('macros_test', () {
    setUpAll(() {
      logWarnings(Level.WARNING);
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Macros Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/macros.h'
        ''') as yaml.YamlMap),
      );
    });
    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('TEST1', () {
      expect(actual.getBindingAsString('TEST1'),
          expected.getBindingAsString('TEST1'));
    });
    test('TEST2', () {
      expect(actual.getBindingAsString('TEST2'),
          expected.getBindingAsString('TEST2'));
    });
    test('TEST3', () {
      expect(actual.getBindingAsString('TEST3'),
          expected.getBindingAsString('TEST3'));
    });

    test('TEST4', () {
      expect(actual.getBindingAsString('TEST4'),
          expected.getBindingAsString('TEST4'));
    });

    test('TEST5', () {
      expect(actual.getBindingAsString('TEST5'),
          expected.getBindingAsString('TEST5'));
    });
    test('TEST6', () {
      expect(actual.getBindingAsString('TEST6'),
          expected.getBindingAsString('TEST6'));
    });
    test('TEST8', () {
      expect(actual.getBindingAsString('TEST8'),
          expected.getBindingAsString('TEST8'));
    });
  });
}

Library expectedLibrary() {
  return Library(
    name: 'NativeLibrary',
    bindings: [
      Constant(name: 'TEST1', rawType: 'double', rawValue: '1.1'),
      Constant(name: 'TEST2', rawType: 'int', rawValue: '10'),
      Constant(name: 'TEST3', rawType: 'double', rawValue: '11.1'),
      Constant(name: 'TEST4', rawType: 'String', rawValue: "'test'"),
      Constant(name: 'TEST5', rawType: 'int', rawValue: '4'),
      Constant(name: 'TEST6', rawType: 'int', rawValue: '1'),
      Constant(name: 'TEST8', rawType: 'int', rawValue: '5'),
    ],
  );
}
