// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Declaration-Declaration Collision', () {
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
      ]);
      final l2 = Library(name: 'Bindings', bindings: [
        Struc(name: 'TestStruc'),
        Struc(name: 'TestStruc_1'),
        EnumClass(name: 'TestEnum'),
        EnumClass(name: 'TestEnum_1'),
        Func(
            name: 'testFunc',
            lookupSymbolName: 'testFunc',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Func(
            name: 'testFunc_1',
            lookupSymbolName: 'testFunc',
            returnType: Type.nativeType(SupportedNativeType.Void)),
      ]);

      expect(l1.generate(), l2.generate());
    });
  });
}
