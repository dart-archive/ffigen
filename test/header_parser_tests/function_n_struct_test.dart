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
  group('function_n_struct_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Function And Struct Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/function_n_struct.h'
        ''') as yaml.YamlMap),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });
    test('func1 struct pointer parameter', () {
      expect(actual.getBindingAsString('func1'),
          expected.getBindingAsString('func1'));
    });
    test('func2 incomplete array parameter', () {
      expect(actual.getBindingAsString('func2'),
          expected.getBindingAsString('func2'));
    });
    test('Struct2 nested struct member', () {
      expect(actual.getBindingAsString('Struct2'),
          expected.getBindingAsString('Struct2'));
    });
    test('Struct3 flexible array member', () {
      expect((actual.getBinding('Struct3') as Struc).members.isEmpty, true);
    });
    test('Struct4 bit field member', () {
      expect((actual.getBinding('Struct4') as Struc).members.isEmpty, true);
    });
    test('Struct5 incompleted struct member', () {
      expect((actual.getBinding('Struct5') as Struc).members.isEmpty, true);
    });
    test('Struct6 typedef constant array', () {
      expect(actual.getBindingAsString('Struct6'),
          expected.getBindingAsString('Struct6'));
    });
    test('func3 constant typedef array parameter', () {
      expect(actual.getBindingAsString('func3'),
          expected.getBindingAsString('func3'));
    });
  });
}

Library expectedLibrary() {
  final struc1 = Struc(name: 'Struct1', members: [
    Member(
      name: 'a',
      type: Type.nativeType(SupportedNativeType.Int32),
    ),
  ]);
  final struc2 = Struc(name: 'Struct2', members: [
    Member(
      name: 'a',
      type: Type.struct(struc1),
    ),
  ]);
  final struc3 = Struc(name: 'Struct3');
  return Library(
    name: 'Bindings',
    bindings: [
      struc1,
      struc2,
      struc3,
      Func(
        name: 'func1',
        parameters: [
          Parameter(name: 's', type: Type.pointer(Type.struct(struc2))),
        ],
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Func(
        name: 'func2',
        parameters: [
          Parameter(name: 's', type: Type.pointer(Type.struct(struc3))),
        ],
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Func(
        name: 'func3',
        parameters: [
          Parameter(
              name: 'a',
              type: Type.pointer(Type.nativeType(SupportedNativeType.Int32))),
        ],
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Struc(name: 'Struct4'),
      Struc(name: 'Struct5'),
      Struc(name: 'Struct6', members: [
        Member(
            name: 'a',
            type: Type.constantArray(
                2,
                Type.constantArray(
                    10, Type.nativeType(SupportedNativeType.Int32))))
      ]),
    ],
  );
}
