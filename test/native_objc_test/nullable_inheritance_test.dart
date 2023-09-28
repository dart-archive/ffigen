// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'nullable_inheritance_bindings.dart';
import 'util.dart';

void main() {
  late NullableInheritanceTestObjCLibrary lib;
  late NullableBase nullableBase;
  late NullableChild nullableChild;
  late NSObject obj;
  group('Nullable inheritance', () {
    setUpAll(() {
      logWarnings();
      final dylib =
          File('test/native_objc_test/nullable_inheritance_test.dylib');
      verifySetupFile(dylib);
      lib = NullableInheritanceTestObjCLibrary(
          DynamicLibrary.open(dylib.absolute.path));
      nullableBase = NullableBase.new1(lib);
      nullableChild = NullableChild.new1(lib);
      obj = NSObject.new1(lib);
      generateBindingsForCoverage('nullable');
    });

    group('Base', () {
      test('Nullable arguments', () {
        expect(nullableBase.nullableArg_(obj), false);
        expect(nullableBase.nullableArg_(null), true);
      });

      test('Non-null arguments', () {
        expect(nullableBase.nonNullArg_(obj), false);
      });

      test('Nullable return', () {
        expect(nullableBase.nullableReturn_(false), isA<NSObject>());
        expect(nullableBase.nullableReturn_(true), null);
      });

      test('Non-null return', () {
        expect(nullableBase.nonNullReturn(), isA<NSObject>());
      });
    });

    group('Child', () {
      test('Nullable arguments, changed to non-null', () {
        expect(nullableChild.nullableArg_(obj), false);
      });

      test('Non-null arguments, changed to nullable', () {
        expect(nullableChild.nonNullArg_(obj), false);
        expect(nullableChild.nonNullArg_(null), true);
      });

      test('Nullable return, changed to non-null', () {
        expect(nullableChild.nullableReturn_(false), isA<NSObject>());
      });

      test('Non-null return, changed to nullable', () {
        expect(nullableChild.nonNullReturn(), null);
      });
    });
  });
}
