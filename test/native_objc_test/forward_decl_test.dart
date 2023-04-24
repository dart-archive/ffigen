// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'forward_decl_bindings.dart';
import 'util.dart';

void main() {
  late ForwardDeclTestObjCLibrary lib;

  group('forward decl', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/forward_decl_test.dylib');
      verifySetupFile(dylib);
      lib =
          ForwardDeclTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('forward_decl');
    });

    test('Forward declared class', () {
      expect(ForwardDeclaredClass.get123(lib), 123);
    });
  });
}
