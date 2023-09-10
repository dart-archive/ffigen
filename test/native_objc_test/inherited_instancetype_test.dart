// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

// Regression tests for https://github.com/dart-lang/ffigen/issues/486.

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'inherited_instancetype_bindings.dart';
import 'util.dart';

void main() {
  late InheritedInstancetypeTestObjCLibrary lib;

  group('inheritedInstancetype', () {
    setUpAll(() {
      logWarnings();
      final dylib =
          File('test/native_objc_test/inherited_instancetype_test.dylib');
      verifySetupFile(dylib);
      lib = InheritedInstancetypeTestObjCLibrary(
          DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('inherited_instancetype');
    });

    test('Ordinary init method', () {
      final ChildClass child = ChildClass.alloc(lib).init();
      expect(child.field, 123);
      final ChildClass sameChild = child.getSelf();
      sameChild.field = 456;
      expect(child.field, 456);
    });

    test('Custom create method', () {
      final ChildClass child = ChildClass.create(lib);
      expect(child.field, 123);
      final ChildClass sameChild = child.getSelf();
      sameChild.field = 456;
      expect(child.field, 456);
    });

    test('Polymorphism', () {
      final ChildClass child = ChildClass.alloc(lib).init();
      final BaseClass base = child;

      // Calling base.getSelf() should still go through ChildClass.getSelf, so
      // the result will have a compile time type of BaseClass, but a runtime
      // type of ChildClass.
      final BaseClass sameChild = base.getSelf();
      expect(sameChild, isA<ChildClass>());
    });
  });
}
