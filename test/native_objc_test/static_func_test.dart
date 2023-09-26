// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'static_func_bindings.dart';
import 'util.dart';

void main() {
  late StaticFuncTestObjCLibrary lib;

  group('static functions', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/static_func_test.dylib');
      verifySetupFile(dylib);
      lib =
          StaticFuncTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('static_func');
    });

    test('Static function involving ObjC objects', () {
      expect(lib.staticFuncReturningNSString().length, 12);
      expect(lib.staticFuncReturningNSString().toString(), "Hello World!");
    });
  });
}
