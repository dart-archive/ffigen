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
      final library = Library(name: 'Bindings', bindings: [
        Struct(name: 'abstract'),
        Struct(name: 'abstract'),
        Struct(name: 'if'),
        EnumClass(name: 'return'),
        EnumClass(name: 'export'),
        Func(name: 'show', returnType: NativeType(SupportedNativeType.Void)),
        Func(
            name: 'implements',
            parameters: [
              Parameter(
                type: intType,
                name: 'if',
              ),
              Parameter(
                type: intType,
                name: 'abstract',
              ),
              Parameter(
                type: intType,
                name: 'in',
              ),
            ],
            returnType: NativeType(SupportedNativeType.Void)),
        Constant(
          name: 'else',
          rawType: 'int',
          rawValue: '0',
        ),
        Typealias(name: 'var', type: NativeType(SupportedNativeType.Void)),
      ]);
      matchLibraryWithExpected(
          library, 'reserved_keyword_collision_test_output.dart', [
        'test',
        'collision_tests',
        'expected_bindings',
        '_expected_reserved_keyword_collision_bindings.dart',
      ]);
    });
  });
}
