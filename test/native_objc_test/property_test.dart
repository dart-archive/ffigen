// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

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
  });
}
