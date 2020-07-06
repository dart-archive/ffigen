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

Library actual, expected;
final functionPrefix = 'fff';
final structPrefix = 'sss';
final enumPrefix = 'eee';

final functionPrefixReplacedWith = 'rf';
final structPrefixReplacedWith = 'rs';
final enumPrefixReplacedWith = 're';

void main() {
  group('Global Prefix Test', () {
    setUpAll(() {
      Logger.root.onRecord.listen((log) {
        if (log.level > Level.INFO) {
          print(
              'prefix_test.dart: ${log.level.name.padRight(8)}: ${log.message}');
        }
      });
      expected = expectedLibrary();
      actual = parser.parse(Config.fromYaml(yaml.loadYaml('''
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
      expect(binding(actual, '${functionPrefix}func1'),
          binding(expected, '${functionPrefix}func1'));
    });
    test('Struct prefix', () {
      expect(binding(actual, '${structPrefix}Struct1'),
          binding(expected, '${structPrefix}Struct1'));
    });
    test('Enum prefix', () {
      expect(binding(actual, '${enumPrefix}Enum1'),
          binding(expected, '${enumPrefix}Enum1'));
    });
    test('Function prefix-replacement', () {
      expect(
          binding(
              actual, '${functionPrefix}${functionPrefixReplacedWith}func2'),
          binding(
              expected, '${functionPrefix}${functionPrefixReplacedWith}func2'));
    });
    test('Struct prefix-replacement', () {
      expect(
          binding(actual, '${structPrefix}${structPrefixReplacedWith}Struct2'),
          binding(
              expected, '${structPrefix}${structPrefixReplacedWith}Struct2'));
    });
    test('Enum prefix-replacement', () {
      expect(binding(actual, '${enumPrefix}${enumPrefixReplacedWith}Enum2'),
          binding(expected, '${enumPrefix}${enumPrefixReplacedWith}Enum2'));
    });
  });
}

/// Extracts a binding's string with a given name from a library.
String binding(Library lib, String name) {
  return lib.bindings
      .firstWhere((element) => element.name == name)
      .toBindingString(lib.writer)
      .string;
}

Library expectedLibrary() {
  final struc1 = Struc(name: '${structPrefix}Struct1');
  final struc2 =
      Struc(name: '${structPrefix}${structPrefixReplacedWith}Struct2');
  return Library(
    bindings: [
      Func(
        name: '${functionPrefix}func1',
        lookupSymbolName: 'func1',
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
        lookupSymbolName: 'test_func2',
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
