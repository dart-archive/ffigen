// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'nullable_bindings.dart';
import 'util.dart';

void main() {
  late NullableTestObjCLibrary lib;
  NullableInterface? nullableInterface;
  NSObject? obj;
  group('method calls', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/nullable_test.dylib');
      verifySetupFile(dylib);
      lib = NullableTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      nullableInterface = NullableInterface.new1(lib);
      obj = NSObject.new1(lib);
      generateBindingsForCoverage('nullable');
    });

    group('Nullable property', () {
      test('Not null', () {
        nullableInterface!.nullableObjectProperty = obj!;
        expect(nullableInterface!.nullableObjectProperty, obj!);
      });
      test('Null', () {
        nullableInterface!.nullableObjectProperty = null;
        expect(nullableInterface!.nullableObjectProperty, null);
      });
    });

    group('Nullable return', () {
      test('Not null', () {
        expect(NullableInterface.returnNil_(lib, false), isA<NSObject>());
      });
      test('Null', () {
        expect(NullableInterface.returnNil_(lib, true), null);
      });
    }, skip: "TODO(#334): enable this test");

    group('Nullable arguments', () {
      test('Not null', () {
        expect(
            NullableInterface.isNullWithNullableNSObjectArg_(lib, obj!), false);
      });
      test('Null', () {
        expect(
            NullableInterface.isNullWithNullableNSObjectArg_(lib, null), true);
      });
    });

    group('Not-nullable arguments', () {
      test('Not null', () {
        expect(
            NullableInterface.isNullWithNotNullableNSObjectPtrArg_(lib, obj!),
            false);
      });
    });
  });
}
