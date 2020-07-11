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
  group('functions_test', () {
    setUpAll(() {
      expected = expectedLibrary();

      Logger.root.onRecord.listen((log) {
        if (log.level > Level.INFO) {
          print(
              'functions_test.dart: ${log.level.name.padRight(8)}: ${log.message}');
        }
      });
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Functions Test'
${strings.output}: 'unused'
${strings.libclang_dylib_folder}: 'tool/wrapped_libclang'
${strings.headers}:
  - 'test/header_parser_tests/functions.h'
${strings.headerFilter}:
  ${strings.include}:
    - 'functions.h'
        ''') as yaml.YamlMap),
      );
    });
    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('func1', () {
      expect(actual.getBinding('func1'), expected.getBinding('func1'));
    });
    test('func2', () {
      expect(actual.getBinding('func2'), expected.getBinding('func2'));
    });
    test('func3', () {
      expect(actual.getBinding('func3'), expected.getBinding('func3'));
    });

    test('func4', () {
      expect(actual.getBinding('func4'), expected.getBinding('func4'));
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
            )
          ]),
    ],
  );
}
