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

    newMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.new1(lib);
      obj1.setCounter_(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 2);
    }

    test('new methods ref count correctly', () {
      // To get the GC to work correctly, the references to the objects all have
      // to be in a separate function.
      final counter = calloc<Int32>();
      counter.value = 0;
      newMethodsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });

    allocMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.alloc(lib).initWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.castFrom(ArcTestObject.alloc(lib).init());
      obj2.setCounter_(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.allocTheThing(lib).initWithCounter_(counter);
      expect(counter.value, 3);
    }

    test('alloc and init methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      allocMethodsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });

    copyMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 1);
      final obj2 = obj1.copyMe();
      expect(counter.value, 2);
      final obj3 = obj1.makeACopy();
      expect(counter.value, 3);
      final obj4 = obj1.copyWithZone_(nullptr);
      expect(counter.value, 4);
      final obj5 = obj1.copy();
      expect(counter.value, 5);
    }

    test('copy methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      copyMethodsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });

    autoreleaseMethodsInner(Pointer<Int32> counter) {
      final obj = ArcTestObject.makeAndAutorelease_(lib, counter);
      expect(counter.value, 1);
    }

    test('autorelease methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;

      final pool1 = lib.createAutoreleasePool();
      autoreleaseMethodsInner(counter);
      doGC();
      // The autorelease pool is still holding a reference to the object.
      expect(counter.value, 1);
      lib.destroyAutoreleasePool(pool1);
      expect(counter.value, 0);

      final pool2 = lib.createAutoreleasePool();
      final obj = ArcTestObject.makeAndAutorelease_(lib, counter);
      expect(counter.value, 1);
      doGC();
      expect(counter.value, 1);
      lib.destroyAutoreleasePool(pool2);
      // The obj variable still holds a reference to the object.
      expect(counter.value, 1);
      obj.release();
      expect(counter.value, 0);

      calloc.free(counter);
    });

    assignPropertiesInnerInner(Pointer<Int32> counter, ArcTestObject outerObj) {
      final assignObj = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 2);
      outerObj.assignedProperty = assignObj;
      expect(counter.value, 2);
      expect(assignObj, outerObj.assignedProperty);
      // To test that outerObj isn't holding a reference to assignObj, we let
      // assignObj go out of scope, but keep outerObj in scope. This is
      // dangerous because outerObj now has a dangling reference, so don't
      // access that reference.
    }

    assignPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 1);
      assignPropertiesInnerInner(counter, outerObj);
      doGC();
      // assignObj has been cleaned up.
      expect(counter.value, 1);
    }

    test('assign properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      assignPropertiesInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });

    retainPropertiesInnerInner(Pointer<Int32> counter, ArcTestObject outerObj) {
      final retainObj = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 2);
      outerObj.retainedProperty = retainObj;
      expect(counter.value, 2);
      expect(retainObj, outerObj.retainedProperty);
    }

    retainPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 1);
      retainPropertiesInnerInner(counter, outerObj);
      doGC();
      // retainObj is still around, because outerObj retains a reference to it.
      expect(counter.value, 2);
    }

    test('retain properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      // The getters of retain properties retain+autorelease the value. So we
      // need an autorelease pool.
      final pool = lib.createAutoreleasePool();
      retainPropertiesInner(counter);
      doGC();
      expect(counter.value, 1);
      lib.destroyAutoreleasePool(pool);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    copyPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 1);

      final copyObj = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 2);
      outerObj.copiedProperty = copyObj;
      // Copy properties make a copy of the object, so now we have 3 objects.
      expect(counter.value, 3);
      expect(copyObj, isNot(outerObj.copiedProperty));

      final anotherCopy = outerObj.copiedProperty;
      // The getter doesn't copy the object.
      expect(counter.value, 3);
      expect(anotherCopy, outerObj.copiedProperty);
    }

    test('copy properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      // The getters of copy properties retain+autorelease the value. So we need
      // an autorelease pool.
      final pool = lib.createAutoreleasePool();
      copyPropertiesInner(counter);
      doGC();
      expect(counter.value, 1);
      lib.destroyAutoreleasePool(pool);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    castFromPointerInnerReleaseAndRetain(int address) {
      final fromCast = RefCounted.castFromPointer(
          lib, Pointer<ObjCObject>.fromAddress(address),
          release: true, retain: true);
      expect(fromCast.refCount, 2);
    }

    test('castFromPointer - release and retain', () {
      final obj1 = RefCounted.new1(lib);
      expect(obj1.refCount, 1);

      castFromPointerInnerReleaseAndRetain(obj1.meAsInt());
      doGC();
      expect(obj1.refCount, 1);
    });

    castFromPointerInnerNoReleaseAndRetain(int address) {
      final fromCast = RefCounted.castFromPointer(
          lib, Pointer<ObjCObject>.fromAddress(address),
          release: false, retain: false);
      expect(fromCast.refCount, 1);
    }

    test('castFromPointer - no release and retain', () {
      final obj1 = RefCounted.new1(lib);
      expect(obj1.refCount, 1);

      castFromPointerInnerNoReleaseAndRetain(obj1.meAsInt());
      doGC();
      expect(obj1.refCount, 1);
    });

    test('Manual release', () {
      final counter = calloc<Int32>();
      final obj1 = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.newWithCounter_(lib, counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.newWithCounter_(lib, counter);
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
      final obj1 = ArcTestObject.new1(lib);
      obj1.setCounter_(counter);
      expect(counter.value, 1);
      final obj1b = obj1.unownedReference();
      expect(counter.value, 1);

      // Make a second object so that the counter check in unownedReferenceInner
      // sees some sort of change. Otherwise this test could pass just by the GC
      // not working correctly.
      final obj2 = ArcTestObject.new1(lib);
      obj2.setCounter_(counter);
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
