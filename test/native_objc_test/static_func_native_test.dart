// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

// Keep in sync with static_func_test.dart. These are the same tests, but using
// @Native.

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import 'package:ffi/ffi.dart';
import '../test_utils.dart';
import 'static_func_native_bindings.dart';
import 'util.dart';

typedef IntBlock = ObjCBlock_Int32_Int32;

void main() {
  late StaticFuncTestObjCLibrary lib;
  late void Function(Pointer<Char>, Pointer<Void>) executeInternalCommand;

  group('static functions', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/static_func_test.dylib');
      verifySetupFile(dylib);
      lib = StaticFuncTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      executeInternalCommand = DynamicLibrary.process().lookupFunction<
          Void Function(Pointer<Char>, Pointer<Void>),
          void Function(
              Pointer<Char>, Pointer<Void>)>('Dart_ExecuteInternalCommand');

      generateBindingsForCoverage('static_func');
    });

    doGC() {
      final gcNow = "gc-now".toNativeUtf8();
      executeInternalCommand(gcNow.cast(), nullptr);
      calloc.free(gcNow);
    }

    Pointer<Int32> staticFuncOfObjectRefCountTest(Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final obj = StaticFuncTestObj.newWithCounter_(lib, counter);
      expect(counter.value, 1);

      final outputObj = staticFuncOfObject(lib, obj);
      expect(obj, outputObj);
      expect(counter.value, 1);

      return counter;
    }

    test('Objects passed through static functions have correct ref counts', () {
      using((Arena arena) {
        final (counter) = staticFuncOfObjectRefCountTest(arena);
        doGC();
        expect(counter.value, 0);
      });
    });

    Pointer<Int32> staticFuncOfNullableObjectRefCountTest(Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final obj = StaticFuncTestObj.newWithCounter_(lib, counter);
      expect(counter.value, 1);

      final outputObj = staticFuncOfNullableObject(lib, obj);
      expect(obj, outputObj);
      expect(counter.value, 1);

      return counter;
    }

    test('Nullables passed through static functions have correct ref counts',
        () {
      using((Arena arena) {
        final (counter) = staticFuncOfNullableObjectRefCountTest(arena);
        doGC();
        expect(counter.value, 0);

        expect(staticFuncOfNullableObject(lib, null), isNull);
      });
    });

    Pointer<Void> staticFuncOfBlockRefCountTest() {
      final block = IntBlock.fromFunction(lib, (int x) => 2 * x);
      expect(getBlockRetainCount(block.pointer.cast()), 1);

      final outputBlock = staticFuncOfBlock(lib, block);
      expect(block, outputBlock);
      expect(getBlockRetainCount(block.pointer.cast()), 2);

      return block.pointer.cast();
    }

    test('Blocks passed through static functions have correct ref counts', () {
      final (rawBlock) = staticFuncOfBlockRefCountTest();
      doGC();
      expect(getBlockRetainCount(rawBlock), 0);
    });

    Pointer<Int32> staticFuncReturnsRetainedRefCountTest(Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final outputObj = staticFuncReturnsRetained(lib, counter);
      expect(counter.value, 1);

      return counter;
    }

    test(
        'Objects returned from static functions with NS_RETURNS_RETAINED '
        'have correct ref counts', () {
      using((Arena arena) {
        final (counter) = staticFuncReturnsRetainedRefCountTest(arena);
        doGC();
        expect(counter.value, 0);
      });
    });

    Pointer<Int32> staticFuncOfObjectReturnsRetainedRefCountTest(
        Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final obj = StaticFuncTestObj.newWithCounter_(lib, counter);
      expect(counter.value, 1);

      final outputObj = staticFuncReturnsRetainedArg(lib, obj);
      expect(obj, outputObj);
      expect(counter.value, 1);

      return counter;
    }

    test(
        'Objects passed through static functions with NS_RETURNS_RETAINED '
        'have correct ref counts', () {
      using((Arena arena) {
        final (counter) = staticFuncOfObjectReturnsRetainedRefCountTest(arena);
        doGC();
        expect(counter.value, 0);
      });
    });
  });
}
