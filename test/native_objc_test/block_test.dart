// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import 'package:ffi/ffi.dart';
import '../test_utils.dart';
import 'block_bindings.dart';
import 'util.dart';

// The generated block names are stable but verbose, so typedef them.
typedef IntBlock = ObjCBlock_Int32_Int32;
typedef FloatBlock = ObjCBlock_ffiFloat_ffiFloat;
typedef DoubleBlock = ObjCBlock_ffiDouble_ffiDouble;
typedef Vec4Block = ObjCBlock_Vec4_Vec4;
typedef VoidBlock = ObjCBlock_ffiVoid;
typedef ObjectBlock = ObjCBlock_DummyObject_DummyObject;
typedef NullableObjectBlock = ObjCBlock_DummyObject_DummyObject1;
typedef BlockBlock = ObjCBlock_Int32Int32_Int32Int32;

void main() {
  late BlockTestObjCLibrary lib;
  late void Function(Pointer<Char>, Pointer<Void>) executeInternalCommand;

  group('Blocks', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/block_test.dylib');
      verifySetupFile(dylib);
      lib = BlockTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      executeInternalCommand = DynamicLibrary.process().lookupFunction<
          Void Function(Pointer<Char>, Pointer<Void>),
          void Function(
              Pointer<Char>, Pointer<Void>)>('Dart_ExecuteInternalCommand');

      generateBindingsForCoverage('block');
    });

    doGC() {
      final gcNow = "gc-now".toNativeUtf8();
      executeInternalCommand(gcNow.cast(), nullptr);
      calloc.free(gcNow);
    }

    test('BlockTester is working', () {
      // This doesn't test any Block functionality, just that the BlockTester
      // itself is working correctly.
      final blockTester = BlockTester.makeFromMultiplier_(lib, 10);
      expect(blockTester.call_(123), 1230);
      final intBlock = blockTester.getBlock();
      final blockTester2 = BlockTester.makeFromBlock_(lib, intBlock);
      blockTester2.pokeBlock();
      expect(blockTester2.call_(456), 4560);
    });

    test('Block from function pointer', () {
      final block =
          IntBlock.fromFunctionPointer(lib, Pointer.fromFunction(_add100, 999));
      final blockTester = BlockTester.makeFromBlock_(lib, block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 223);
      expect(block(123), 223);
    });

    int Function(int) makeAdder(int addTo) {
      return (int x) => addTo + x;
    }

    test('Block from function', () {
      final block = IntBlock.fromFunction(lib, makeAdder(4000));
      final blockTester = BlockTester.makeFromBlock_(lib, block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 4123);
      expect(block(123), 4123);
    });

    test('Listener block same thread', () async {
      final hasRun = Completer();
      int value = 0;
      final block = VoidBlock.listener(lib, () {
        value = 123;
        hasRun.complete();
      });

      BlockTester.callOnSameThread_(lib, block);

      await hasRun.future;
      expect(value, 123);
    });

    test('Listener block new thread', () async {
      final hasRun = Completer();
      int value = 0;
      final block = VoidBlock.listener(lib, () {
        value = 123;
        hasRun.complete();
      });

      final thread = BlockTester.callOnNewThread_(lib, block);
      thread.start();

      await hasRun.future;
      expect(value, 123);
    });

    test('Float block', () {
      final block = FloatBlock.fromFunction(lib, (double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callFloatBlock_(lib, block), closeTo(5.79, 1e-6));
    });

    test('Double block', () {
      final block = DoubleBlock.fromFunction(lib, (double x) {
        return x + 4.56;
      });
      expect(block(1.23), closeTo(5.79, 1e-6));
      expect(BlockTester.callDoubleBlock_(lib, block), closeTo(5.79, 1e-6));
    });

    test('Struct block', () {
      using((Arena arena) {
        final inputPtr = arena<Vec4>();
        final input = inputPtr.ref;
        input.x = 1.2;
        input.y = 3.4;
        input.z = 5.6;
        input.w = 7.8;

        final tempPtr = arena<Vec4>();
        final temp = tempPtr.ref;
        final block = Vec4Block.fromFunction(lib, (Vec4 v) {
          // Twiddle the Vec4 components.
          temp.x = v.y;
          temp.y = v.z;
          temp.z = v.w;
          temp.w = v.x;
          return temp;
        });

        final result1 = block(input);
        expect(result1.x, 3.4);
        expect(result1.y, 5.6);
        expect(result1.z, 7.8);
        expect(result1.w, 1.2);

        final result2Ptr = arena<Vec4>();
        final result2 = result2Ptr.ref;
        BlockTester.callVec4Block_(lib, result2Ptr, block);
        expect(result2.x, 3.4);
        expect(result2.y, 5.6);
        expect(result2.z, 7.8);
        expect(result2.w, 1.2);
      });
    });

    test('Object block', () {
      bool isCalled = false;
      final block = ObjectBlock.fromFunction(lib, (DummyObject x) {
        isCalled = true;
        return x;
      });

      final obj = DummyObject.new1(lib);
      final result1 = block(obj);
      expect(result1, obj);
      expect(isCalled, isTrue);

      isCalled = false;
      final result2 = BlockTester.callObjectBlock_(lib, block);
      expect(result2, isNot(obj));
      expect(result2.pointer, isNot(nullptr));
      expect(isCalled, isTrue);
    });

    test('Nullable object block', () {
      bool isCalled = false;
      final block = NullableObjectBlock.fromFunction(lib, (DummyObject? x) {
        isCalled = true;
        return x;
      });

      final obj = DummyObject.new1(lib);
      final result1 = block(obj);
      expect(result1, obj);
      expect(isCalled, isTrue);

      isCalled = false;
      final result2 = block(null);
      expect(result2, isNull);
      expect(isCalled, isTrue);

      isCalled = false;
      final result3 = BlockTester.callNullableObjectBlock_(lib, block);
      expect(result3, isNull);
      expect(isCalled, isTrue);
    });

    test('Block block', () {
      final blockBlock = BlockBlock.fromFunction(lib, (IntBlock intBlock) {
        return IntBlock.fromFunction(lib, (int x) {
          return 3 * intBlock(x);
        });
      });

      final intBlock = IntBlock.fromFunction(lib, (int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 15);

      final result2 = BlockTester.newBlock_withMult_(lib, blockBlock, 2);
      expect(result2(1), 6);
    });

    test('Native block block', () {
      final blockBlock = BlockTester.newBlockBlock_(lib, 7);

      final intBlock = IntBlock.fromFunction(lib, (int x) {
        return 5 * x;
      });
      final result1 = blockBlock(intBlock);
      expect(result1(1), 35);

      final result2 = BlockTester.newBlock_withMult_(lib, blockBlock, 2);
      expect(result2(1), 14);
    });

    Pointer<Void> funcPointerBlockRefCountTest() {
      final block =
          IntBlock.fromFunctionPointer(lib, Pointer.fromFunction(_add100, 999));
      expect(BlockTester.getBlockRetainCount_(lib, block.pointer.cast()), 1);
      return block.pointer.cast();
    }

    test('Function pointer block ref counting', () {
      final rawBlock = funcPointerBlockRefCountTest();
      doGC();
      expect(BlockTester.getBlockRetainCount_(lib, rawBlock), 0);
    });

    Pointer<Void> funcBlockRefCountTest() {
      final block = IntBlock.fromFunction(lib, makeAdder(4000));
      expect(BlockTester.getBlockRetainCount_(lib, block.pointer.cast()), 1);
      return block.pointer.cast();
    }

    test('Function block ref counting', () {
      final rawBlock = funcBlockRefCountTest();
      doGC();
      expect(BlockTester.getBlockRetainCount_(lib, rawBlock), 0);
    });

    (Pointer<Void>, Pointer<Void>, Pointer<Void>)
        blockBlockDartCallRefCountTest() {
      final inputBlock = IntBlock.fromFunction(lib, (int x) {
        return 5 * x;
      });
      final blockBlock = BlockBlock.fromFunction(lib, (IntBlock intBlock) {
        return IntBlock.fromFunction(lib, (int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 15);
      doGC();

      // One reference held by inputBlock object, another bound to the
      // outputBlock lambda.
      expect(
          BlockTester.getBlockRetainCount_(lib, inputBlock.pointer.cast()), 2);

      expect(
          BlockTester.getBlockRetainCount_(lib, blockBlock.pointer.cast()), 1);
      expect(
          BlockTester.getBlockRetainCount_(lib, outputBlock.pointer.cast()), 1);
      return (
        inputBlock.pointer.cast(),
        blockBlock.pointer.cast(),
        outputBlock.pointer.cast()
      );
    }

    test('Calling a block block from Dart has correct ref counting', () {
      final (inputBlock, blockBlock, outputBlock) =
          blockBlockDartCallRefCountTest();
      doGC();

      // This leaks because block functions aren't cleaned up at the moment.
      // TODO(https://github.com/dart-lang/ffigen/issues/428): Fix this leak.
      expect(BlockTester.getBlockRetainCount_(lib, inputBlock), 1);

      expect(BlockTester.getBlockRetainCount_(lib, blockBlock), 0);
      expect(BlockTester.getBlockRetainCount_(lib, outputBlock), 0);
    });

    (Pointer<Void>, Pointer<Void>, Pointer<Void>)
        blockBlockObjCCallRefCountTest() {
      late Pointer<Void> inputBlock;
      final blockBlock = BlockBlock.fromFunction(lib, (IntBlock intBlock) {
        inputBlock = intBlock.pointer.cast();
        return IntBlock.fromFunction(lib, (int x) {
          return 3 * intBlock(x);
        });
      });
      final outputBlock = BlockTester.newBlock_withMult_(lib, blockBlock, 2);
      expect(outputBlock(1), 6);
      doGC();

      expect(BlockTester.getBlockRetainCount_(lib, inputBlock), 2);
      expect(
          BlockTester.getBlockRetainCount_(lib, blockBlock.pointer.cast()), 1);
      expect(
          BlockTester.getBlockRetainCount_(lib, outputBlock.pointer.cast()), 1);
      return (
        inputBlock,
        blockBlock.pointer.cast(),
        outputBlock.pointer.cast()
      );
    }

    test('Calling a block block from ObjC has correct ref counting', () {
      final (inputBlock, blockBlock, outputBlock) =
          blockBlockObjCCallRefCountTest();
      doGC();

      // This leaks because block functions aren't cleaned up at the moment.
      // TODO(https://github.com/dart-lang/ffigen/issues/428): Fix this leak.
      expect(BlockTester.getBlockRetainCount_(lib, inputBlock), 2);

      expect(BlockTester.getBlockRetainCount_(lib, blockBlock), 0);
      expect(BlockTester.getBlockRetainCount_(lib, outputBlock), 0);
    });

    (Pointer<Void>, Pointer<Void>, Pointer<Void>)
        nativeBlockBlockDartCallRefCountTest() {
      final inputBlock = IntBlock.fromFunction(lib, (int x) {
        return 5 * x;
      });
      final blockBlock = BlockTester.newBlockBlock_(lib, 7);
      final outputBlock = blockBlock(inputBlock);
      expect(outputBlock(1), 35);
      doGC();

      // One reference held by inputBlock object, another held internally by the
      // ObjC implementation of the blockBlock.
      expect(
          BlockTester.getBlockRetainCount_(lib, inputBlock.pointer.cast()), 2);

      expect(
          BlockTester.getBlockRetainCount_(lib, blockBlock.pointer.cast()), 1);
      expect(
          BlockTester.getBlockRetainCount_(lib, outputBlock.pointer.cast()), 1);
      return (
        inputBlock.pointer.cast(),
        blockBlock.pointer.cast(),
        outputBlock.pointer.cast()
      );
    }

    test('Calling a native block block from Dart has correct ref counting', () {
      final (inputBlock, blockBlock, outputBlock) =
          nativeBlockBlockDartCallRefCountTest();
      doGC();
      expect(BlockTester.getBlockRetainCount_(lib, inputBlock), 0);
      expect(BlockTester.getBlockRetainCount_(lib, blockBlock), 0);
      expect(BlockTester.getBlockRetainCount_(lib, outputBlock), 0);
    });

    (Pointer<Void>, Pointer<Void>) nativeBlockBlockObjCCallRefCountTest() {
      final blockBlock = BlockTester.newBlockBlock_(lib, 7);
      final outputBlock = BlockTester.newBlock_withMult_(lib, blockBlock, 2);
      expect(outputBlock(1), 14);
      doGC();

      expect(
          BlockTester.getBlockRetainCount_(lib, blockBlock.pointer.cast()), 1);
      expect(
          BlockTester.getBlockRetainCount_(lib, outputBlock.pointer.cast()), 1);
      return (blockBlock.pointer.cast(), outputBlock.pointer.cast());
    }

    test('Calling a native block block from ObjC has correct ref counting', () {
      final (blockBlock, outputBlock) = nativeBlockBlockObjCCallRefCountTest();
      doGC();
      expect(BlockTester.getBlockRetainCount_(lib, blockBlock), 0);
      expect(BlockTester.getBlockRetainCount_(lib, outputBlock), 0);
    });

    (Pointer<Int32>, Pointer<Int32>) objectBlockRefCountTest(Allocator alloc) {
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = ObjectBlock.fromFunction(lib, (DummyObject x) {
        return DummyObject.newWithCounter_(lib, outputCounter);
      });

      final inputObj = DummyObject.newWithCounter_(lib, inputCounter);
      final outputObj = block(inputObj);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      return (inputCounter, outputCounter);
    }

    test('Objects received and returned by blocks have correct ref counts', () {
      using((Arena arena) {
        final (inputCounter, outputCounter) = objectBlockRefCountTest(arena);
        doGC();
        expect(inputCounter.value, 0);
        expect(outputCounter.value, 0);
      });
    });

    (Pointer<Int32>, Pointer<Int32>) objectNativeBlockRefCountTest(
        Allocator alloc) {
      final inputCounter = alloc<Int32>();
      final outputCounter = alloc<Int32>();
      inputCounter.value = 0;
      outputCounter.value = 0;

      final block = ObjectBlock.fromFunction(lib, (DummyObject x) {
        x.setCounter_(inputCounter);
        return DummyObject.newWithCounter_(lib, outputCounter);
      });

      final outputObj = BlockTester.callObjectBlock_(lib, block);
      expect(inputCounter.value, 1);
      expect(outputCounter.value, 1);

      return (inputCounter, outputCounter);
    }

    test(
        'Objects received and returned by native blocks have correct ref counts',
        () {
      using((Arena arena) {
        final (inputCounter, outputCounter) =
            objectNativeBlockRefCountTest(arena);
        doGC();

        // This leaks because block functions aren't cleaned up at the moment.
        // TODO(https://github.com/dart-lang/ffigen/issues/428): Fix this leak.
        expect(inputCounter.value, 1);

        expect(outputCounter.value, 0);
      });
    });

    test('Block fields have sensible values', () {
      final block = IntBlock.fromFunction(lib, makeAdder(4000));
      final blockPtr = block.pointer;
      expect(blockPtr.ref.isa, isNot(0));
      expect(blockPtr.ref.flags, isNot(0)); // Set by Block_copy.
      expect(blockPtr.ref.reserved, 0);
      expect(blockPtr.ref.invoke, isNot(0));
      expect(blockPtr.ref.target, isNot(0));
      final descPtr = blockPtr.ref.descriptor;
      expect(descPtr.ref.reserved, 0);
      expect(descPtr.ref.size, isNot(0));
      expect(descPtr.ref.copy_helper, nullptr);
      expect(descPtr.ref.dispose_helper, nullptr);
      expect(descPtr.ref.signature, nullptr);
    });
  });
}

int _add100(int x) {
  return x + 100;
}
