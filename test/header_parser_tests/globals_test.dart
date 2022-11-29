// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('globals_test', () {
    setUpAll(() {
      logWarnings();
      expected = expectedLibrary();
      actual = parser.parse(
        testConfig('''
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
        '''),
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
  final globalStruct = Struct(name: 'EmptyStruct');
  return Library(
    name: 'Bindings',
    bindings: [
      Global(type: BooleanType(), name: 'coolGlobal'),
      Global(
        type: NativeType(SupportedNativeType.Int32),
        name: 'myInt',
        exposeSymbolAddress: true,
      ),
      Global(
        type: PointerType(NativeType(SupportedNativeType.Int32)),
        name: 'aGlobalPointer',
        exposeSymbolAddress: true,
      ),
      globalStruct,
      Global(
        name: 'globalStruct',
        type: globalStruct,
        exposeSymbolAddress: true,
      ),
      Global(
        name: 'globalStruct_from_alias',
        type: Typealias(
          name: 'EmptyStruct_Alias',
          type: globalStruct,
        ),
        exposeSymbolAddress: true,
      )
    ],
  );
}
