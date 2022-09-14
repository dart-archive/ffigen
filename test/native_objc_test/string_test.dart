// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import '../test_utils.dart';
import 'string_bindings.dart';
import 'util.dart';

void main() {
  late StringTestObjCLibrary lib;

  group('string', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/string_test.dylib');
      verifySetupFile(dylib);
      lib = StringTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      generateBindingsForCoverage('string');
    });

    for (final s in ['Hello', '🇵🇬', 'Embedded\u0000Null']) {
      test('NSString to/from Dart string [$s]', () {
        final ns1 = NSString(lib, s);
        expect(ns1.length, s.length);
        expect(ns1.toString().length, s.length);
        expect(ns1.toString(), s);

        final ns2 = s.toNSString(lib);
        expect(ns2.length, s.length);
        expect(ns2.toString().length, s.length);
        expect(ns2.toString(), s);
      });
    }

    test('strings usable', () {
      final str1 = 'Hello'.toNSString(lib);
      final str2 = 'World!'.toNSString(lib);

      final str3 = StringUtil.strConcat_with_(lib, str1, str2);
      expect(str3.length, 11);
      expect(str3.toString(), "HelloWorld!");
    });
  });
}
