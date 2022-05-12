// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'rename_test_bindings.dart';

void main() {
  late RenameLibrary lib;
  group('rename_test', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/rename_test.dylib');
      verifySetupFile(dylib);
      lib = RenameLibrary(DynamicLibrary.open(dylib.absolute.path));
    });

    test('Renamed class', () {
      final renamed = Renamed.new1(lib);
      renamed.property = 123;
      expect(renamed.property, 123);
    });
  });
}
