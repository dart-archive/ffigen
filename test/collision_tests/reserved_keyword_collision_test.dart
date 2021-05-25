// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('reserved_keyword_collision_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('reserved keyword collision', () {
      final l1 = Library(name: 'Bindings', bindings: [
        Struc(name: 'abstract'),
        Struc(name: 'abstract'),
        Struc(name: 'if'),
        EnumClass(name: 'return'),
        EnumClass(name: 'export'),
        Func(
            name: 'show',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Func(
            name: 'implements',
            parameters: [
              Parameter(
                type: Type.nativeType(SupportedNativeType.Int32),
                name: 'if',
              ),
              Parameter(
                type: Type.nativeType(SupportedNativeType.Int32),
                name: 'abstract',
              ),
              Parameter(
                type: Type.nativeType(SupportedNativeType.Int32),
                name: 'in',
              ),
            ],
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Constant(
          name: 'else',
          rawType: 'int',
          rawValue: '0',
        ),
        Typealias(name: 'var', type: Type.nativeType(SupportedNativeType.Void)),
      ]);
      final l2 = Library(name: 'Bindings', bindings: [
        Struc(name: 'abstract_1'),
        Struc(name: 'abstract_2'),
        Struc(name: 'if_1'),
        EnumClass(name: 'return_1'),
        EnumClass(name: 'export_1'),
        Func(
            name: 'show_1',
            originalName: 'show',
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Func(
            name: 'implements_1',
            originalName: 'implements',
            parameters: [
              Parameter(
                type: Type.nativeType(SupportedNativeType.Int32),
                name: 'if_1',
              ),
              Parameter(
                type: Type.nativeType(SupportedNativeType.Int32),
                name: 'abstract_1',
              ),
              Parameter(
                type: Type.nativeType(SupportedNativeType.Int32),
                name: 'in_1',
              ),
            ],
            returnType: Type.nativeType(SupportedNativeType.Void)),
        Constant(
          name: 'else_1',
          rawType: 'int',
          rawValue: '0',
        ),
        Typealias(
            name: 'var_1', type: Type.nativeType(SupportedNativeType.Void)),
      ]);
      expect(l1.generate(), l2.generate());
    });
  });
}
