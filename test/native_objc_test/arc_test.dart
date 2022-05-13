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
import 'arc_bindings.dart';
import 'util.dart';

void main() {
  late ArcTestObjCLibrary lib;
  late void Function(Pointer<Char>, Pointer<Void>) executeInternalCommand;

  group('Automatic reference counting', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/arc_test.dylib');
      verifySetupFile(dylib);
      lib = ArcTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      executeInternalCommand = DynamicLibrary.process().lookupFunction<
          Void Function(Pointer<Char>, Pointer<Void>),
          void Function(
              Pointer<Char>, Pointer<Void>)>('Dart_ExecuteInternalCommand');

      generateBindingsForCoverage('arc');
    });

    doGC() {
      final gcNow = "gc-now".toNativeUtf8();
      executeInternalCommand(gcNow.cast(), nullptr);
      calloc.free(gcNow);
    }

    makeSomeObjects() {
      final obj1 = ArcTestObject.new1(lib);
      expect(ArcTestObject.getTotalObjects(lib), 1);
      final obj2 = ArcTestObject.new1(lib);
      expect(ArcTestObject.getTotalObjects(lib), 2);
      final obj3 = ArcTestObject.new1(lib);
      expect(ArcTestObject.getTotalObjects(lib), 3);
    }

    test('Verify ref counts', () {
      makeSomeObjects();
      doGC();
      expect(ArcTestObject.getTotalObjects(lib), 0);
    });
  });
}
