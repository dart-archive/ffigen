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
  group('nested_parsing_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Nested Parsing Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/nested_parsing.h'
${strings.structs}:
  ${strings.include}:
    ${strings.names}:
      - Struct1
        ''') as yaml.YamlMap),
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
  });
}

Library expectedLibrary() {
  final struc2 = Struc(name: 'Struct2', members: [
    Member(
      name: 'e',
      type: Type.nativeType(SupportedNativeType.Int32),
    ),
    Member(
      name: 'f',
      type: Type.nativeType(SupportedNativeType.Int32),
    ),
  ]);
  return Library(
    name: 'Bindings',
    bindings: [
      struc2,
      Struc(name: 'Struct1', members: [
        Member(
          name: 'a',
          type: Type.nativeType(SupportedNativeType.Int32),
        ),
        Member(
          name: 'b',
          type: Type.nativeType(SupportedNativeType.Int32),
        ),
        Member(name: 'struct2', type: Type.pointer(Type.struct(struc2))),
      ]),
    ],
  );
}
