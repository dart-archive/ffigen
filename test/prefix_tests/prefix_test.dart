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
  prefix: $functionPrefix
structs:
  prefix: $structPrefix
enums:
  prefix: $enumPrefix
    ''') as yaml.YamlMap));
    });

    test('Function prefix', () {
      expect(binding(actual, 'func1'), binding(expected, 'func1'));
    });
    test('Struct prefix', () {
      expect(binding(actual, 'Struct1'), binding(expected, 'Struct1'));
    });
    test('Enum prefix', () {
      expect(binding(actual, 'Enum1'), binding(expected, 'Enum1'));
    });
  });
}

/// Extracts a binding's string from a library.
String binding(Library lib, String name) {
  return lib.bindings
      .firstWhere((element) => element.name == name)
      .toBindingString(lib.writer)
      .string;
}

Library expectedLibrary() {
  return Library(
    functionPrefix: functionPrefix,
    structPrefix: structPrefix,
    enumPrefix: enumPrefix,
    bindings: [
      Func(
        name: 'func1',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Struc(name: 'Struct1'),
      EnumClass(
        name: 'Enum1',
        enumConstants: [
          EnumConstant(name: 'a', value: 0),
          EnumConstant(name: 'b', value: 1),
          EnumConstant(name: 'c', value: 2),
        ],
      ),
    ],
  );
}
