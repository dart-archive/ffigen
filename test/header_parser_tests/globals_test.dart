// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
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
  group('globals_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Globals Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/globals.h'
  ${strings.includeDirectives}:
    - '**globals.h'
${strings.globals}:
  ${strings.exclude}:
    - GlobalIgnore
  ${strings.symbolAddress}:
    ${strings.include}:
      - myInt
      - pointerToLongDouble
      - globalStruct
${strings.compilerOpts}: '-Wno-nullability-completeness'
        ''') as yaml.YamlMap),
      );
    });

    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('Parse global Values', () {
      expect(actual.getBindingAsString('coolGlobal'),
          expected.getBindingAsString('coolGlobal'));
      expect(actual.getBindingAsString('myInt'),
          expected.getBindingAsString('myInt'));
      expect(actual.getBindingAsString('aGlobalPointer'),
          expected.getBindingAsString('aGlobalPointer'));
    });

    test('Ignore global values', () {
      expect(() => actual.getBindingAsString('GlobalIgnore'),
          throwsA(TypeMatcher<NotFoundException>()));
      expect(() => actual.getBindingAsString('longDouble'),
          throwsA(TypeMatcher<NotFoundException>()));
      expect(() => actual.getBindingAsString('pointerToLongDouble'),
          throwsA(TypeMatcher<NotFoundException>()));
    });
  });
}

Library expectedLibrary() {
  final globalStruc = Struc(name: 'EmptyStruct');
  return Library(
    name: 'Bindings',
    bindings: [
      Global(type: Type.boolean(), name: 'coolGlobal'),
      Global(
        type: Type.nativeType(SupportedNativeType.Int32),
        name: 'myInt',
        exposeSymbolAddress: true,
      ),
      Global(
        type: Type.pointer(Type.nativeType(SupportedNativeType.Int32)),
        name: 'aGlobalPointer',
        exposeSymbolAddress: true,
      ),
      globalStruc,
      Global(
        name: 'globalStruct',
        type: Type.struct(globalStruc),
        exposeSymbolAddress: true,
      ),
    ],
  );
}
