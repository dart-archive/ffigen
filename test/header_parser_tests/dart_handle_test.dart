// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cli_util/cli_util.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('dart_handle_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Dart_Handle Test'
${strings.output}: 'unused'
${strings.compilerOpts}: '-I${path.join(getSdkPath(), "include")}'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/dart_handle.h'
  ${strings.includeDirectives}:
    - '**dart_handle.h'
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
    test('struc1', () {
      expect(actual.getBindingAsString('struc1'),
          expected.getBindingAsString('struc1'));
    });
    test('struc2', () {
      expect(actual.getBindingAsString('struc2'),
          expected.getBindingAsString('struc2'));
    });
  });
}

Library expectedLibrary() {
  final namedTypedef = Typedef(
    name: 'typedef1',
    typedefType: TypedefType.C,
    returnType: Type.nativeType(SupportedNativeType.Void),
    parameters: [Parameter(type: Type.handle())],
  );
  return Library(
    name: 'NativeLibrary',
    bindings: [
      Func(
        name: 'func1',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
        parameters: [
          Parameter(type: Type.handle()),
        ],
      ),
      Func(
        name: 'func2',
        returnType: Type.handle(),
      ),
      Func(
        name: 'func3',
        returnType: Type.pointer(Type.pointer(Type.handle())),
        parameters: [
          Parameter(
            type: Type.pointer(Type.handle()),
          ),
        ],
      ),
      Func(
        name: 'func4',
        returnType: Type.nativeType(SupportedNativeType.Void),
        parameters: [
          Parameter(
            type: Type.pointer(Type.nativeFunc(namedTypedef)),
          ),
        ],
      ),
      // struc1 should have no members.
      Struc(name: 'struc1'),
      Struc(
        name: 'struc2',
        members: [
          Member(name: 'h', type: Type.pointer(Type.handle())),
        ],
      ),
    ],
  );
}
