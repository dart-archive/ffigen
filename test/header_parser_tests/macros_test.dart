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
  ${strings.includeDirectives}:
    - '**macros.h'
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
    test('TEST9', () {
      expect(actual.getBindingAsString('TEST9'),
          expected.getBindingAsString('TEST9'));
    });
    test('TEST10', () {
      expect(actual.getBindingAsString('TEST10'),
          expected.getBindingAsString('TEST10'));
    });
    test('TEST11', () {
      expect(actual.getBindingAsString('TEST11'),
          expected.getBindingAsString('TEST11'));
    });
    test('TEST12', () {
      expect(actual.getBindingAsString('TEST12'),
          expected.getBindingAsString('TEST12'));
    });
    test('TEST13', () {
      expect(actual.getBindingAsString('TEST13'),
          expected.getBindingAsString('TEST13'));
    });
    test('TEST14', () {
      expect(actual.getBindingAsString('TEST14'),
          expected.getBindingAsString('TEST14'));
    });
    test('TEST15', () {
      expect(actual.getBindingAsString('TEST15'),
          expected.getBindingAsString('TEST15'));
    });
    test('TEST16', () {
      expect(actual.getBindingAsString('TEST16'),
          expected.getBindingAsString('TEST16'));
    });
    test('TEST17', () {
      expect(actual.getBindingAsString('TEST17'),
          expected.getBindingAsString('TEST17'));
    });
    test('TEST18', () {
      expect(actual.getBindingAsString('TEST18'),
          expected.getBindingAsString('TEST18'));
    });
    test('TEST19', () {
      expect(actual.getBindingAsString('TEST19'),
          expected.getBindingAsString('TEST19'));
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
      Constant(name: 'TEST9', rawType: 'String', rawValue: r"'\$dollar'"),
      Constant(name: 'TEST10', rawType: 'String', rawValue: r"'test\'s'"),
      Constant(name: 'TEST11', rawType: 'String', rawValue: r"'\x80'"),
      Constant(
          name: 'TEST12', rawType: 'String', rawValue: r"'hello\n\t\r\v\b'"),
      Constant(name: 'TEST13', rawType: 'String', rawValue: r"'test\\'"),
      Constant(
          name: 'TEST14', rawType: 'double', rawValue: strings.doubleInfinity),
      Constant(
          name: 'TEST15',
          rawType: 'double',
          rawValue: strings.doubleNegativeInfinity),
      Constant(name: 'TEST16', rawType: 'double', rawValue: strings.doubleNaN),
      Constant(name: 'TEST17', rawType: 'int', rawValue: "0"),
      Constant(name: 'TEST18', rawType: 'int', rawValue: "4"),
      Constant(name: 'TEST19', rawType: 'int', rawValue: "8"),
    ],
  );
}
