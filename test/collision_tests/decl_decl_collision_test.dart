// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Declaration-Declaration Collision', () {
    test('struct-func', () {
      final l1 = Library(bindings: [
        Func(
          name: 'test',
          returnType: Type.nativeType(SupportedNativeType.Void),
        ),
        Struc(name: 'test'),
      ]);
      final l2 = Library(bindings: [
        Func(
          name: 'test',
          returnType: Type.nativeType(SupportedNativeType.Void),
        ),
        Struc(name: 'test_1'),
      ]);

      expect(l1.generate(), l2.generate());
    });
  });
}
