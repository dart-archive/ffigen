// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/config_provider.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:ffigen/src/strings.dart' as strings;

import '../test_utils.dart';

Library actual, expected;

void main() {
  group('unnamed_enums_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Unnamed Enums Test'
${strings.output}: 'unused'
${strings.headers}:
  - 'test/header_parser_tests/unnamed_enums.h'
${strings.headerFilter}:
  ${strings.include}:
    - 'unnamed_enums.h'
${strings.enums}:
  ${strings.exclude}:
    ${strings.names}:
      - Named
        ''') as yaml.YamlMap),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('Parse unnamed enum Values', () {
      expect(actual.getBindingAsString('A'), expected.getBindingAsString('A'));
      expect(actual.getBindingAsString('B'), expected.getBindingAsString('B'));
      expect(actual.getBindingAsString('C'), expected.getBindingAsString('C'));
    });

    test('Ignore unnamed enums inside typedefs', () {
      expect(() => actual.getBindingAsString('E'),
          throwsA(TypeMatcher<NotFoundException>()));
      expect(() => actual.getBindingAsString('F'),
          throwsA(TypeMatcher<NotFoundException>()));
      expect(() => actual.getBindingAsString('G'),
          throwsA(TypeMatcher<NotFoundException>()));
    });
  });
}

Library expectedLibrary() {
  return Library(
    name: 'Bindings',
    bindings: [
      Constant(
        name: 'A',
        rawType: 'int',
        rawValue: '1',
      ),
      Constant(
        name: 'B',
        rawType: 'int',
        rawValue: '2',
      ),
      Constant(
        name: 'C',
        rawType: 'int',
        rawValue: '3',
      ),
    ],
  );
}
