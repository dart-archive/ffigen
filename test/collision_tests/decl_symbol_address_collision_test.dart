// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

late Library actual;
void main() {
  group('decl_symbol_address_collision_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = Library(
        name: 'Bindings',
        header:
            '// ignore_for_file: unused_element, camel_case_types, non_constant_identifier_names\n',
        bindings: [
          Struct(name: 'addresses'),
          Struct(name: '_SymbolAddresses'),
          EnumClass(name: 'Bindings'),
          Func(
            name: '_library',
            returnType: NativeType(SupportedNativeType.Void),
            exposeSymbolAddress: true,
            exposeFunctionTypedefs: true,
          ),
          Func(
            name: '_SymbolAddresses_1',
            returnType: NativeType(SupportedNativeType.Void),
            exposeSymbolAddress: true,
          ),
        ],
      );
    });
    test('declaration and symbol address conflict', () {
      matchLibraryWithExpected(actual, [
        'test',
        'debug_generated',
        'collision_test_decl_symbol_address_collision_output.dart'
      ], [
        'test',
        'collision_tests',
        'expected_bindings',
        '_expected_decl_symbol_address_collision_bindings.dart'
      ]);
    });
  });
}
