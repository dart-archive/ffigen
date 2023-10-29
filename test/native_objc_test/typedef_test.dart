// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'typedef_bindings.dart';
import 'util.dart';

void main() {
  late TypedefTestObjCLibrary lib;

  group('typedef', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/typedef_test.dylib');
      verifySetupFile(dylib);
      lib = TypedefTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('typedef');
    });

    test('Regression test for #386', () {
      // https://github.com/dart-lang/ffigen/issues/386
      // Make sure that the typedef DartSomeClassPtr is for SomeClass.
      final DartSomeClassPtr instance = SomeClass.new1(lib);
      expect(instance.pointer, isNot(nullptr));
    });
  });
}
