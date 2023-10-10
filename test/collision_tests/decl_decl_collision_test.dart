// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('decl_decl_collision_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('declaration conflict', () {
      final library = Library(name: 'Bindings', bindings: [
        Struct(name: 'TestStruct'),
        Struct(name: 'TestStruct'),
        EnumClass(name: 'TestEnum'),
        EnumClass(name: 'TestEnum'),
        Func(
            name: 'testFunc', returnType: NativeType(SupportedNativeType.Void)),
        Func(
            name: 'testFunc', returnType: NativeType(SupportedNativeType.Void)),
        Constant(
          originalName: 'Test_Macro',
          name: 'Test_Macro',
          rawType: 'int',
          rawValue: '0',
        ),
        Constant(
          originalName: 'Test_Macro',
          name: 'Test_Macro',
          rawType: 'int',
          rawValue: '0',
        ),
        Typealias(
            name: 'testAlias', type: NativeType(SupportedNativeType.Void)),
        Typealias(
            name: 'testAlias', type: NativeType(SupportedNativeType.Void)),

        /// Conflicts across declarations.
        Struct(name: 'testCrossDecl'),
        Func(
            name: 'testCrossDecl',
            returnType: NativeType(SupportedNativeType.Void)),
        Constant(name: 'testCrossDecl', rawValue: '0', rawType: 'int'),
        EnumClass(name: 'testCrossDecl'),
        Typealias(
            name: 'testCrossDecl', type: NativeType(SupportedNativeType.Void)),

        /// Conflicts with ffi library prefix, name of prefix is changed.
        Struct(name: 'ffi'),
        Func(name: 'ffi1', returnType: NativeType(SupportedNativeType.Void)),
      ]);
      matchLibraryWithExpected(
          library, 'decl_decl_collision_test_output.dart', [
        'test',
        'collision_tests',
        'expected_bindings',
        '_expected_decl_decl_collision_bindings.dart',
      ]);
    });
  });
}
