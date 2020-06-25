// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'native_functions_bindings.dart' as bindings;

void main() {
  group('Tests for native functions', () {
    setUpAll(() {
      var dylibName = 'test/native_functions_test/native_functions.so';
      if (Platform.isMacOS) {
        dylibName = 'test/native_functions_test/native_functions.dylib';
      } else if (Platform.isWindows) {
        dylibName = r'test\native_functions_test\native_functions.dll';
      }
      bindings.init(DynamicLibrary.open(dylibName));
    });
    test('uint8_t', () {
      expect(bindings.Function1Uint8(pow(2, 8).toInt()), 42);
    });
    test('uint16_t', () {
      expect(bindings.Function1Uint16(pow(2, 16).toInt()), 42);
    });
    test('uint32_t', () {
      expect(bindings.Function1Uint32(pow(2, 32).toInt()), 42);
    });
    test('uint64_t', () {
      expect(bindings.Function1Uint64(pow(2, 64).toInt()), 42);
    });
    test('int8_t', () {
      expect(
          bindings.Function1Int8(pow(2, 7).toInt()), -pow(2, 7).toInt() + 42);
    });
    test('int16_t', () {
      expect(bindings.Function1Int16(pow(2, 15).toInt()),
          -pow(2, 15).toInt() + 42);
    });
    test('int32_t', () {
      expect(bindings.Function1Int32(pow(2, 31).toInt()),
          -pow(2, 31).toInt() + 42);
    });
    test('int64_t', () {
      expect(bindings.Function1Int64(pow(2, 63).toInt()),
          -pow(2, 63).toInt() + 42);
    });
    test('intptr_t', () {
      expect(bindings.Function1IntPtr(0), 42);
    });
    test('float', () {
      expect(bindings.Function1Float(0), 42.0);
    });
    test('double', () {
      expect(bindings.Function1Double(0), 42.0);
    });
  });
}
