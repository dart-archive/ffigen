// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'swift_class_bindings.dart';
import 'util.dart';

void main() {
  late SwiftClassTestLibrary lib;
  group('swift_class_test', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/swift_class_test.dylib');
      verifySetupFile(dylib);
      lib = SwiftClassTestLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('swift_class');
    });

    test('Renamed class', () {
      final swiftObject = MySwiftClass.new1(lib);
      expect(swiftObject.getValue(), 123);
      swiftObject.setValueWithX_(456);
      expect(swiftObject.getValue(), 456);
    });
  });
}
