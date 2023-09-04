// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'property_bindings.dart';
import 'util.dart';

void main() {
  late PropertyInterface testInstance;
  late PropertyTestObjCLibrary lib;

  group('properties', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/property_test.dylib');
      verifySetupFile(dylib);
      lib = PropertyTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      testInstance = PropertyInterface.new1(lib);
      generateBindingsForCoverage('property');
    });

    group('instance properties', () {
      test('read-only property', () {
        expect(testInstance.readOnlyProperty, 7);
      });

      test('read-write property', () {
        testInstance.readWriteProperty = 23;
        expect(testInstance.readWriteProperty, 23);
      });
    });

    group('class properties', () {
      test('read-only property', () {
        expect(PropertyInterface.getClassReadOnlyProperty(lib), 42);
      });

      test('read-write property', () {
        PropertyInterface.setClassReadWriteProperty(lib, 101);
        expect(PropertyInterface.getClassReadWriteProperty(lib), 101);
      });
    });

    group('Regress #608', () {
      test('Structs', () {
        final inputPtr = calloc<Vec4>();
        final input = inputPtr.ref;
        input.x = 1.2;
        input.y = 3.4;
        input.z = 5.6;
        input.w = 7.8;

        final resultPtr = calloc<Vec4>();
        final result = resultPtr.ref;
        testInstance.structProperty = input;
        testInstance.getStructProperty(resultPtr);
        expect(result.x, 1.2);
        expect(result.y, 3.4);
        expect(result.z, 5.6);
        expect(result.w, 7.8);

        calloc.free(inputPtr);
        calloc.free(resultPtr);
      });

      test('Floats', () {
        testInstance.floatProperty = 1.23;
        expect(testInstance.floatProperty, closeTo(1.23, 1e-6));
      });

      test('Doubles', () {
        testInstance.doubleProperty = 1.23;
        expect(testInstance.doubleProperty, 1.23);
      });
    });
  });
}
