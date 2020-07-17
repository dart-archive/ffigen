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
final functionPrefix = 'fff';
final structPrefix = 'sss';
final enumPrefix = 'eee';

final functionPrefixReplacedWith = 'rf';
final structPrefixReplacedWith = 'rs';
final enumPrefixReplacedWith = 're';

void main() {
  group('prefix_test', () {
    setUpAll(() {
      expected = expectedLibrary();
      actual = parser.parse(Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Prefix Test'
${strings.output}: 'unused'
${strings.libclang_dylib_folder}: 'tool/wrapped_libclang'
${strings.headers}:
  - 'test/prefix_tests/prefix.h'
${strings.headerFilter}:
  ${strings.include}:
    - 'prefix.h'

functions:
  ${strings.prefix}: $functionPrefix
  ${strings.prefix_replacement}:
    'test_': '$functionPrefixReplacedWith'

structs:
  ${strings.prefix}: $structPrefix
  ${strings.prefix_replacement}:
    'Test_': '$structPrefixReplacedWith'

enums:
  ${strings.prefix}: $enumPrefix
  ${strings.prefix_replacement}:
    'Test_': '$enumPrefixReplacedWith'

    ''') as yaml.YamlMap));
    });

    test('Function prefix', () {
      expect(actual.getBindingAsString('${functionPrefix}func1'),
          expected.getBindingAsString('${functionPrefix}func1'));
    });
    test('Struct prefix', () {
      expect(actual.getBindingAsString('${structPrefix}Struct1'),
          expected.getBindingAsString('${structPrefix}Struct1'));
    });
    test('Enum prefix', () {
      expect(actual.getBindingAsString('${enumPrefix}Enum1'),
          expected.getBindingAsString('${enumPrefix}Enum1'));
    });
    test('Function prefix-replacement', () {
      expect(
          actual.getBindingAsString(
              '${functionPrefix}${functionPrefixReplacedWith}func2'),
          expected.getBindingAsString(
              '${functionPrefix}${functionPrefixReplacedWith}func2'));
    });
    test('Struct prefix-replacement', () {
      expect(
          actual.getBindingAsString(
              '${structPrefix}${structPrefixReplacedWith}Struct2'),
          expected.getBindingAsString(
              '${structPrefix}${structPrefixReplacedWith}Struct2'));
    });
    test('Enum prefix-replacement', () {
      expect(
          actual.getBindingAsString(
              '${enumPrefix}${enumPrefixReplacedWith}Enum2'),
          expected.getBindingAsString(
              '${enumPrefix}${enumPrefixReplacedWith}Enum2'));
    });
  });
}

Library expectedLibrary() {
  final struc1 = Struc(name: '${structPrefix}Struct1');
  final struc2 =
      Struc(name: '${structPrefix}${structPrefixReplacedWith}Struct2');
  return Library(
    name: 'Bindings',
    bindings: [
      Func(
        name: '${functionPrefix}func1',
        originalName: 'func1',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
        parameters: [
          Parameter(
            name: 's',
            type: Type.pointer(Type.struct(struc1)),
          ),
        ],
      ),
      Func(
        name: '${functionPrefix}${functionPrefixReplacedWith}func2',
        originalName: 'test_func2',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
        parameters: [
          Parameter(
            name: 's',
            type: Type.pointer(Type.struct(struc2)),
          ),
        ],
      ),
      struc1,
      struc2,
      EnumClass(
        name: '${enumPrefix}Enum1',
        enumConstants: [
          EnumConstant(name: 'a', value: 0),
          EnumConstant(name: 'b', value: 1),
          EnumConstant(name: 'c', value: 2),
        ],
      ),
      EnumClass(
        name: '${enumPrefix}${enumPrefixReplacedWith}Enum2',
        enumConstants: [
          EnumConstant(name: 'e', value: 0),
          EnumConstant(name: 'f', value: 1),
          EnumConstant(name: 'g', value: 2),
        ],
      ),
    ],
  );
}
