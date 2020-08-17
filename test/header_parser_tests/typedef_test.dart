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
  group('typedef_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'Bindings'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/typedef.h'
${strings.structs}:
  ${strings.exclude}:
    - ExcludedStruct
    - _ExcludedStruct
        ''') as yaml.YamlMap),
      );
    });

    test('Library output', () {
      expect(actual.generate(), expected.generate());
    });
  });
}

Library expectedLibrary() {
  final namedTypedef = Typedef(
    name: 'NamedFunctionProto',
    typedefType: TypedefType.C,
    returnType: Type.nativeType(SupportedNativeType.Void),
  );

  final excludedNtyperef = Struc(name: 'NTyperef1');
  return Library(
    name: 'Bindings',
    bindings: [
      Struc(name: 'Struct1', members: [
        Member(
          name: 'named',
          type: Type.pointer(Type.nativeFunc(namedTypedef)),
        ),
        Member(
          name: 'unnamed',
          type: Type.pointer(Type.nativeFunc(Typedef(
            name: '_typedefC_1',
            typedefType: TypedefType.C,
            returnType: Type.nativeType(SupportedNativeType.Void),
          ))),
        ),
      ]),
      Func(
        name: 'func1',
        parameters: [
          Parameter(
            name: 'named',
            type: Type.pointer(Type.nativeFunc(namedTypedef)),
          ),
          Parameter(
            name: 'unnamed',
            type: Type.pointer(Type.nativeFunc(Typedef(
              name: '_typedefC_2',
              typedefType: TypedefType.C,
              parameters: [
                Parameter(type: Type.nativeType(SupportedNativeType.Int32)),
              ],
              returnType: Type.nativeType(SupportedNativeType.Void),
            ))),
          ),
        ],
        returnType: Type.pointer(Type.nativeFunc(namedTypedef)),
      ),
      Struc(name: 'AnonymousStructInTypedef'),
      Struc(name: 'NamedStructInTypedef'),
      excludedNtyperef,
      Func(
        name: 'func2',
        returnType: Type.nativeType(SupportedNativeType.Void),
        parameters: [
          Parameter(type: Type.pointer(Type.struct(excludedNtyperef)))
        ],
      ),
      EnumClass(name: 'AnonymousEnumInTypedef'),
      EnumClass(name: 'NamedEnumInTypedef'),
    ],
  );
}
