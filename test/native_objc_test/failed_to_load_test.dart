// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'failed_to_load_bindings.dart';
import 'util.dart';

void main() {
  group('Failed to load', () {
    setUpAll(() {
      logWarnings();
      generateBindingsForCoverage('failed_to_load');
    });

    test('Failed to load Objective-C class', () {
      // Load from the host executable, which is missing all the classes for
      // this test, but has the core ObjC functions, such as objc_getClass. The
      // library should load ok, because the classes are lazy loaded.
      final lib = FailedToLoadTestObjCLibrary(DynamicLibrary.executable());

      // But when we try to instantiate one of the classes, we get an error.
      expect(
          () => ClassThatWillFailToLoad.new1(lib),
          throwsA(predicate(
              (e) => e.toString().contains('ClassThatWillFailToLoad'))));
    });
  });
}
