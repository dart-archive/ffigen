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

void main() {
  group('header_parser', () {
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
      expect(binding(actual, 'func1'), binding(expected, 'func1'));
    });
    test('func2', () {
      expect(binding(actual, 'func2'), binding(expected, 'func2'));
    });
    test('func3', () {
      expect(binding(actual, 'func3'), binding(expected, 'func3'));
    });

    test('func4', () {
      expect(binding(actual, 'func4'), binding(expected, 'func4'));
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
    bindings: [
      Func(
        name: 'func1',
        lookupSymbolName: 'func1',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Func(
        name: 'func2',
        lookupSymbolName: 'func2',
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
        lookupSymbolName: 'func3',
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
          lookupSymbolName: 'func4',
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
