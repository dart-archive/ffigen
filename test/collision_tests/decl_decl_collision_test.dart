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
      final l1 = Library(name: 'Bindings', bindings: [
        Struc(name: 'TestStruc'),
        Struc(name: 'TestStruc'),
        EnumClass(name: 'TestEnum'),
        EnumClass(name: 'TestEnum'),
        Func(
            name: 'testFunc',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Func(
            name: 'testFunc',
            returnType: Type.nativeType(SupportedNativeType.Void)),
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

        /// Conflicts across declarations.
        Struc(name: 'testCrossDecl'),
        Func(
            name: 'testCrossDecl',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Constant(name: 'testCrossDecl', rawValue: '0', rawType: 'int'),
        EnumClass(name: 'testCrossDecl'),

        /// Conflicts with ffi library prefix, name of prefix is changed.
        Struc(name: 'ffi'),
        Func(
            name: 'ffi_1',
            returnType: Type.nativeType(SupportedNativeType.Void)),
      ]);
      final l2 = Library(name: 'Bindings', bindings: [
        Struc(name: 'TestStruc'),
        Struc(name: 'TestStruc_1'),
        EnumClass(name: 'TestEnum'),
        EnumClass(name: 'TestEnum_1'),
        Func(
            name: 'testFunc',
            originalName: 'testFunc',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Func(
            name: 'testFunc_1',
            originalName: 'testFunc',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Constant(
          originalName: 'Test_Macro',
          name: 'Test_Macro',
          rawType: 'int',
          rawValue: '0',
        ),
        Constant(
          originalName: 'Test_Macro',
          name: 'Test_Macro_1',
          rawType: 'int',
          rawValue: '0',
        ),
        Struc(name: 'testCrossDecl', originalName: 'testCrossDecl'),
        Func(
            name: 'testCrossDecl_1',
            originalName: 'testCrossDecl',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Constant(name: 'testCrossDecl_2', rawValue: '0', rawType: 'int'),
        EnumClass(name: 'testCrossDecl_3'),
        Struc(name: 'ffi'),
        Func(
            name: 'ffi_1',
            returnType: Type.nativeType(SupportedNativeType.Void)),
      ]);

      expect(l1.generate(), l2.generate());
    });
  });
}
