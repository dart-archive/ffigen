// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual, expected;
final functionPrefix = 'fff';
final structPrefix = 'sss';
final enumPrefix = 'eee';
final macroPrefix = 'mmm';

void main() {
  group('rename_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Rename Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/rename_tests/rename.h'

${strings.functions}:
  ${strings.rename}:
    'test_(.*)': '\$1'
    '.*': '$functionPrefix\$0'
    'fullMatch_func3': 'func3'
  ${strings.memberRename}:
    'memberRename_.*':
      '_(.*)': '\$1'
      'fullMatch': 'fullMatchSuccess'
      '': 'unnamed'

${strings.structs}:
  ${strings.rename}:
    'Test_(.*)': '\$1'
    '.*': '$structPrefix\$0'
    'FullMatchStruct3': 'Struct3'
  ${strings.memberRename}:
    'MemberRenameStruct4':
      '_(.*)': '\$1'
      'fullMatch': 'fullMatchSuccess'
    '.*':
      '_(.*)': '\$1'

${strings.enums}:
  ${strings.rename}:
    'Test_(.*)': '\$1'
    '.*': '$enumPrefix\$0'
    'FullMatchEnum3': 'Enum3'
  ${strings.memberRename}:
    'MemberRenameEnum4':
      '_(.*)': '\$1'
      'fullMatch': 'fullMatchSuccess'

${strings.unnamedEnums}:
  ${strings.rename}:
    '_(.*)': '\$1'
    'unnamedFullMatch': 'unnamedFullMatchSuccess'

${strings.macros}:
  ${strings.rename}:
    'Test_(.*)': '\$1'
    '.*': '$macroPrefix\$0'
    'FullMatchMacro3': 'Macro3'

${strings.typedefs}:
  ${strings.rename}:
    'Struct5_Alias': 'Struct5_Alias_Renamed'
    ''') as yaml.YamlMap));
    });

    test('Function addPrefix', () {
      expect(actual.getBindingAsString('${functionPrefix}func1'),
          expected.getBindingAsString('${functionPrefix}func1'));
    });
    test('Struct addPrefix', () {
      expect(actual.getBindingAsString('${structPrefix}Struct1'),
          expected.getBindingAsString('${structPrefix}Struct1'));
    });
    test('Enum addPrefix', () {
      expect(actual.getBindingAsString('${enumPrefix}Enum1'),
          expected.getBindingAsString('${enumPrefix}Enum1'));
    });
    test('Macro addPrefix', () {
      expect(actual.getBindingAsString('${macroPrefix}Macro1'),
          expected.getBindingAsString('${macroPrefix}Macro1'));
    });
    test('Function rename with pattern', () {
      expect(actual.getBindingAsString('func2'),
          expected.getBindingAsString('func2'));
    });
    test('Struct rename with pattern', () {
      expect(actual.getBindingAsString('Struct2'),
          expected.getBindingAsString('Struct2'));
    });
    test('Enum rename with pattern', () {
      expect(actual.getBindingAsString('Enum2'),
          expected.getBindingAsString('Enum2'));
    });
    test('Macro rename with pattern', () {
      expect(actual.getBindingAsString('Macro2'),
          expected.getBindingAsString('Macro2'));
    });
    test('Function full match rename', () {
      expect(actual.getBindingAsString('func3'),
          expected.getBindingAsString('func3'));
    });
    test('Struct full match rename', () {
      expect(actual.getBindingAsString('Struct3'),
          expected.getBindingAsString('Struct3'));
    });
    test('Enum full match rename', () {
      expect(actual.getBindingAsString('Enum3'),
          expected.getBindingAsString('Enum3'));
    });
    test('Macro full match rename', () {
      expect(actual.getBindingAsString('Macro3'),
          expected.getBindingAsString('Macro3'));
    });
    test('Struct member rename', () {
      expect(actual.getBindingAsString('${structPrefix}MemberRenameStruct4'),
          expected.getBindingAsString('${structPrefix}MemberRenameStruct4'));
    });
    test('Any Struct member rename', () {
      expect(actual.getBindingAsString('${structPrefix}AnyMatchStruct5'),
          expected.getBindingAsString('${structPrefix}AnyMatchStruct5'));
    });
    test('Function member rename', () {
      expect(actual.getBindingAsString('${functionPrefix}memberRename_func4'),
          expected.getBindingAsString('${functionPrefix}memberRename_func4'));
    });
    test('Enum member rename', () {
      expect(actual.getBindingAsString('${enumPrefix}MemberRenameEnum4'),
          expected.getBindingAsString('${enumPrefix}MemberRenameEnum4'));
    });
    test('unnamed Enum regexp rename', () {
      expect(actual.getBindingAsString('unnamed_underscore'),
          expected.getBindingAsString('unnamed_underscore'));
    });
    test('unnamed Enum full match rename', () {
      expect(actual.getBindingAsString('unnamedFullMatchSuccess'),
          expected.getBindingAsString('unnamedFullMatchSuccess'));
    });
    test('typedef rename', () {
      expect(actual.getBindingAsString('Struct5_Alias_Renamed'),
          expected.getBindingAsString('Struct5_Alias_Renamed'));
    });
  });
}

Library expectedLibrary() {
  final struc1 = Struc(name: '${structPrefix}Struct1');
  final struc2 = Struc(name: 'Struct2');
  final struc3 = Struc(name: 'Struct3');
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
        name: 'func2',
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
      Func(
        name: 'func3',
        originalName: 'fullMatch_func3',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
        parameters: [
          Parameter(
            name: 's',
            type: Type.pointer(Type.struct(struc3)),
          ),
        ],
      ),
      Func(
        name: '${functionPrefix}memberRename_func4',
        originalName: 'memberRename_func4',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
        parameters: [
          Parameter(
            name: 'underscore',
            type: Type.importedType(intType),
          ),
          Parameter(
            name: 'fullMatchSuccess',
            type: Type.importedType(floatType),
          ),
          Parameter(
            name: 'unnamed',
            type: Type.importedType(intType),
          ),
        ],
      ),
      Func(
        name: '${functionPrefix}typedefRenameFunc',
        originalName: 'typedefRenameFunc',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
        parameters: [
          Parameter(
            name: 's',
            type: Type.typealias(Typealias(
                name: 'Struct5_Alias_Renamed',
                type: Type.struct(Struc(name: '${structPrefix}Struct5')))),
          ),
        ],
      ),
      struc1,
      struc2,
      struc3,
      Struc(
        name: '${structPrefix}MemberRenameStruct4',
        members: [
          Member(
            name: 'underscore',
            type: Type.importedType(intType),
          ),
          Member(
            name: 'fullMatchSuccess',
            type: Type.importedType(floatType),
          ),
        ],
      ),
      Struc(
        name: '${structPrefix}AnyMatchStruct5',
        members: [
          Member(
            name: 'underscore',
            type: Type.importedType(intType),
          ),
        ],
      ),
      EnumClass(
        name: '${enumPrefix}Enum1',
        enumConstants: [
          EnumConstant(name: 'a', value: 0),
          EnumConstant(name: 'b', value: 1),
          EnumConstant(name: 'c', value: 2),
        ],
      ),
      EnumClass(
        name: 'Enum2',
        enumConstants: [
          EnumConstant(name: 'e', value: 0),
          EnumConstant(name: 'f', value: 1),
          EnumConstant(name: 'g', value: 2),
        ],
      ),
      EnumClass(
        name: 'Enum3',
        enumConstants: [
          EnumConstant(name: 'i', value: 0),
          EnumConstant(name: 'j', value: 1),
          EnumConstant(name: 'k', value: 2),
        ],
      ),
      EnumClass(
        name: '${enumPrefix}MemberRenameEnum4',
        enumConstants: [
          EnumConstant(name: 'underscore', value: 0),
          EnumConstant(name: 'fullMatchSuccess', value: 1),
        ],
      ),
      Constant(
        name: '${macroPrefix}Macro1',
        rawType: 'int',
        rawValue: '1',
      ),
      Constant(
        name: 'Macro2',
        rawType: 'int',
        rawValue: '2',
      ),
      Constant(
        name: 'Macro3',
        rawType: 'int',
        rawValue: '3',
      ),
      Constant(
        name: 'unnamed_underscore',
        rawType: 'int',
        rawValue: '0',
      ),
      Constant(
        name: 'unnamedFullMatchSuccess',
        rawType: 'int',
        rawValue: '1',
      ),
    ],
  );
}
