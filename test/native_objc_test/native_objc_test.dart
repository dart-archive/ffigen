// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import '../test_utils.dart';
import 'native_objc_test_bindings.dart';

void main() {
  late NativeObjCLibrary lib;
  group('native_objc_test', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/native_objc_test.dylib');
      verifySetupFile(dylib);
      lib = NativeObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
    });

    test('Interface basics, with Foo', () {
      final foo1 = Foo.makeFoo_(lib, 3.14159);
      final foo2 = Foo.makeFoo_(lib, 2.71828);

      expect(foo1.intVal, 3);
      expect(foo2.intVal, 2);

      expect(foo1.multiply_withOtherFoo_(false, foo2), 8);
      expect(foo1.multiply_withOtherFoo_(true, foo2), 6);

      foo1.intVal = 100;
      expect(foo1.multiply_withOtherFoo_(false, foo2), 8);
      expect(foo1.multiply_withOtherFoo_(true, foo2), 200);

      foo2.setDoubleVal_(1.61803);
      expect(foo1.multiply_withOtherFoo_(false, foo2), 5);
      expect(foo1.multiply_withOtherFoo_(true, foo2), 200);
    });
  });
}
