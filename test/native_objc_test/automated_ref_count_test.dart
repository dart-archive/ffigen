// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import 'package:ffi/ffi.dart';
import '../test_utils.dart';
import 'automated_ref_count_bindings.dart';
import 'util.dart';

void main() {
  late AutomatedRefCountTestObjCLibrary lib;
  late void Function(Pointer<Char>, Pointer<Void>) executeInternalCommand;

  group('Automatic reference counting', () {
    setUpAll(() {
      logWarnings();
      final dylib =
          File('test/native_objc_test/automated_ref_count_test.dylib');
      verifySetupFile(dylib);
      lib = AutomatedRefCountTestObjCLibrary(
          DynamicLibrary.open(dylib.absolute.path));

      executeInternalCommand = DynamicLibrary.process().lookupFunction<
          Void Function(Pointer<Char>, Pointer<Void>),
          void Function(
              Pointer<Char>, Pointer<Void>)>('Dart_ExecuteInternalCommand');

      generateBindingsForCoverage('automated_ref_count');
    });

    doGC() {
      final gcNow = "gc-now".toNativeUtf8();
      executeInternalCommand(gcNow.cast(), nullptr);
      calloc.free(gcNow);
    }

    verifyRefCountsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 3);
    }

    test('Verify ref counts', () {
      // To get the GC to work correctly, the references to the objects all have
      // to be in a separate function.
      final counter = calloc<Int32>();
      verifyRefCountsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });

    test('Manual release', () {
      final counter = calloc<Int32>();
      final obj1 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 3);

      // GC to clean up temporaries created between alloc and initWithCounter_.
      doGC();
      expect(counter.value, 3);

      obj1.release();
      expect(counter.value, 2);
      obj2.release();
      expect(counter.value, 1);
      obj3.release();
      expect(counter.value, 0);

      expect(() => obj1.release(), throwsStateError);
      calloc.free(counter);
    });

    ArcTestObject unownedReferenceInner2(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 1);
      final obj1b = obj1.unownedReference();
      expect(counter.value, 1);

      // Make a second object so that the counter check in unownedReferenceInner
      // sees some sort of change. Otherwise this test could pass just by the GC
      // not working correctly.
      final obj2 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 2);

      return obj1b;
    }

    unownedReferenceInner(Pointer<Int32> counter) {
      final obj1b = unownedReferenceInner2(counter);
      doGC(); // Collect obj1 and obj2.
      // The underlying object obj1 and obj1b points to still exists, because
      // obj1b took a reference to it. So we still have 1 object.
      expect(counter.value, 1);
    }

    test("Method that returns a reference we don't own", () {
      // Most ObjC API methods return us a reference without incrementing the
      // ref count (ie, returns us a reference we don't own). So the wrapper
      // object has to take ownership by calling retain. This test verifies that
      // is working correctly by holding a reference to an object returned by a
      // method, after the original wrapper object is gone.
      final counter = calloc<Int32>();
      unownedReferenceInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });
  });
}
