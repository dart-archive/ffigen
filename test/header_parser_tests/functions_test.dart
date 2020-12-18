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

late Library actual, expected;

void main() {
  group('functions_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Functions Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/functions.h'
  ${strings.includeDirectives}:
    - '**functions.h'
        ''') as yaml.YamlMap),
      );
    });
    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('func1', () {
      expect(actual.getBindingAsString('func1'),
          expected.getBindingAsString('func1'));
    });
    test('func2', () {
      expect(actual.getBindingAsString('func2'),
          expected.getBindingAsString('func2'));
    });
    test('func3', () {
      expect(actual.getBindingAsString('func3'),
          expected.getBindingAsString('func3'));
    });

    test('func4', () {
      expect(actual.getBindingAsString('func4'),
          expected.getBindingAsString('func4'));
    });

    test('func5', () {
      expect(actual.getBindingAsString('func5'),
          expected.getBindingAsString('func5'));
    });
  });
}

Library expectedLibrary() {
  return Library(
    name: 'Bindings',
    bindings: [
      Func(
        name: 'func1',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Func(
        name: 'func2',
        returnType: Type.nativeType(
          SupportedNativeType.Int32,
        ),
        parameters: [
          Parameter(
            name: '',
            type: Type.nativeType(
              SupportedNativeType.Int16,
            ),
          ),
        ],
      ),
      Func(
        name: 'func3',
        returnType: Type.nativeType(
          SupportedNativeType.Double,
        ),
        parameters: [
          Parameter(
            type: Type.nativeType(
              SupportedNativeType.Float,
            ),
          ),
          Parameter(
            name: 'a',
            type: Type.nativeType(
              SupportedNativeType.Int8,
            ),
          ),
          Parameter(
            name: '',
            type: Type.nativeType(
              SupportedNativeType.Int64,
            ),
          ),
          Parameter(
            name: 'b',
            type: Type.nativeType(
              SupportedNativeType.Int32,
            ),
          ),
        ],
      ),
      Func(
          name: 'func4',
          returnType: Type.pointer(Type.nativeType(SupportedNativeType.Void)),
          parameters: [
            Parameter(
                type: Type.pointer(
                    Type.pointer(Type.nativeType(SupportedNativeType.Int8)))),
            Parameter(type: Type.nativeType(SupportedNativeType.Double)),
            Parameter(
              type: Type.pointer(Type.pointer(
                  Type.pointer(Type.nativeType(SupportedNativeType.Int32)))),
            ),
          ]),
      Func(
        name: 'func5',
        returnType: Type.nativeType(SupportedNativeType.Void),
        parameters: [
          Parameter(
              name: 'a',
              type: Type.pointer(Type.nativeFunc(Typedef(
                name: 'shortHand',
                returnType: Type.nativeType(SupportedNativeType.Void),
                typedefType: TypedefType.C,
                parameters: [
                  Parameter(
                      type: Type.pointer(Type.nativeFunc(Typedef(
                    name: 'b',
                    returnType: Type.nativeType(SupportedNativeType.Void),
                    typedefType: TypedefType.C,
                  )))),
                ],
              )))),
          Parameter(
              name: 'b',
              type: Type.pointer(Type.nativeFunc(Typedef(
                name: '_typedefC_2',
                returnType: Type.nativeType(SupportedNativeType.Void),
                typedefType: TypedefType.C,
              )))),
        ],
      ),
    ],
  );
}
