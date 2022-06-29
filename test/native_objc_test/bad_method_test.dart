// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'bad_method_test_bindings.dart';
import 'util.dart';

void main() {
  late NativeObjCLibrary lib;
  group('bad_method_test', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/bad_method_test.dylib');
      verifySetupFile(dylib);
      lib = NativeObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('bad_method');
    });

    test("Test methods that weren't skipped", () {
      final obj = BadMethodTestObject.new1(lib);
      final structPtr = obj.incompletePointerReturn();
      expect(structPtr.address, 1234);
      expect(obj.incompletePointerParam_(structPtr), 1234);
    });
  });
}
