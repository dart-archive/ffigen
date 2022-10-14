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
import 'block_bindings.dart';
import 'util.dart';

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
      final block = ObjCBlock.fromFunctionPointer(
          lib, Pointer.fromFunction(_add100, 999));
      final blockTester = BlockTester.makeFromBlock_(lib, block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 223);
      expect(block(123), 223);
    });

    int Function(int) makeAdder(int addTo) {
      return (int x) => addTo + x;
    }

    test('Block from function', () {
      final block = ObjCBlock.fromFunction(lib, makeAdder(4000));
      final blockTester = BlockTester.makeFromBlock_(lib, block);
      blockTester.pokeBlock();
      expect(blockTester.call_(123), 4123);
      expect(block(123), 4123);
    });

    Pointer<Void> funcPointerBlockRefCountTest() {
      final block = ObjCBlock.fromFunctionPointer(
          lib, Pointer.fromFunction(_add100, 999));
      expect(BlockTester.getBlockRetainCount_(lib, block.pointer.cast()), 1);
      return block.pointer.cast();
    }

    test('Function pointer block ref counting', () {
      final rawBlock = funcPointerBlockRefCountTest();
      doGC();
      expect(BlockTester.getBlockRetainCount_(lib, rawBlock.cast()), 0);
    });

    Pointer<Void> funcBlockRefCountTest() {
      final block = ObjCBlock.fromFunction(lib, makeAdder(4000));
      expect(BlockTester.getBlockRetainCount_(lib, block.pointer.cast()), 1);
      return block.pointer.cast();
    }

    test('Function pointer block ref counting', () {
      final rawBlock = funcBlockRefCountTest();
      doGC();
      expect(BlockTester.getBlockRetainCount_(lib, rawBlock.cast()), 0);
    });

    test('Block fields have sensible values', () {
      final block = ObjCBlock.fromFunction(lib, makeAdder(4000));
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
