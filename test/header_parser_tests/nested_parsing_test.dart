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
  group('nested_parsing_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Nested Parsing Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/nested_parsing.h'
${strings.structs}:
  ${strings.exclude}:
    - Struct2
        '''),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('Struct1', () {
      expect(actual.getBindingAsString('Struct1'),
          expected.getBindingAsString('Struct1'));
    });
    test('Struct2', () {
      expect(actual.getBindingAsString('Struct2'),
          expected.getBindingAsString('Struct2'));
    });
    test('Struct3', () {
      expect(actual.getBindingAsString('Struct3'),
          expected.getBindingAsString('Struct3'));
    });
    test('Struct4', () {
      expect(actual.getBindingAsString('Struct4'),
          expected.getBindingAsString('Struct4'));
    });
    test('Struct5', () {
      expect(actual.getBindingAsString('Struct5'),
          expected.getBindingAsString('Struct5'));
    });
    test('Struct6', () {
      expect(actual.getBindingAsString('Struct6'),
          expected.getBindingAsString('Struct6'));
    });
  });
}

Library expectedLibrary() {
  final struct2 = Struct(name: 'Struct2', members: [
    Member(
      name: 'e',
      type: intType,
    ),
    Member(
      name: 'f',
      type: intType,
    ),
  ]);
  final unnamedInternalStruct = Struct(name: 'UnnamedStruct1', members: [
    Member(
      name: 'a',
      type: intType,
    ),
    Member(
      name: 'b',
      type: intType,
    ),
  ]);
  return Library(
    name: 'Bindings',
    bindings: [
      unnamedInternalStruct,
      struct2,
      Struct(name: 'Struct1', members: [
        Member(
          name: 'a',
          type: intType,
        ),
        Member(
          name: 'b',
          type: intType,
        ),
        Member(name: 'struct2', type: PointerType(struct2)),
      ]),
      Struct(name: 'Struct3', members: [
        Member(
          name: 'a',
          type: intType,
        ),
        Member(
          name: 'b',
          type: unnamedInternalStruct,
        ),
      ]),
      Struct(name: 'EmptyStruct'),
      Struct(name: 'Struct4'),
      Struct(name: 'Struct5'),
      Struct(
        name: 'Struct6',
        members: [
          Member(
            name: '',
            type: Union(
              name: 'UnnamedUnion1',
              members: [
                Member(
                  name: 'a',
                  type: floatType,
                ),
              ],
            ),
          ),
          Member(
            name: 'c',
            type: Union(
              name: 'UnnamedUnion2',
              members: [
                Member(
                  name: 'b',
                  type: floatType,
                ),
              ],
            ),
          ),
          Member(
            name: 'e',
            type: Union(
              name: 'UnnamedUnion3',
              members: [
                Member(
                  name: 'd',
                  type: floatType,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
