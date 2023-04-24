// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('unnamed_enums_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Unnamed Enums Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/unnamed_enums.h'
${strings.enums}:
  ${strings.exclude}:
    - Named
${strings.unnamedEnums}:
  ${strings.exclude}:
    - B
        '''),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('Parse unnamed enum Values', () {
      expect(actual.getBindingAsString('A'), expected.getBindingAsString('A'));
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
        name: 'C',
        rawType: 'int',
        rawValue: '3',
      ),
    ],
  );
}
