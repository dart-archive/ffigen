// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import '../test_utils.dart';
import 'nullable_bindings.dart';

void main() {
  late NullableTestObjCLibrary lib;
  late NullableInterface nullableInterface;
  late NSObject obj;
  group('method calls', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/nullable_test.dylib');
      verifySetupFile(dylib);
      lib = NullableTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      nullableInterface = NullableInterface.new1(lib);
      obj = NSObject.new1(lib);
    });

    test('generate_bindings', () {
      final config = Config.fromYaml(loadYaml(
          File(path.join('test', 'native_objc_test', 'nullable_config.yaml'))
              .readAsStringSync()) as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'nullable_test.dart'),
      );
      library.generateFile(file);

      try {
        final actual = file.readAsStringSync();
        final expected = File(path.join(config.output)).readAsStringSync();
        expect(actual, expected);
        if (file.existsSync()) {
          file.delete();
        }
      } catch (e) {
        print('Failed test: Debug generated file: ${file.absolute.path}');
        rethrow;
      }
    });

    group('Nullable property', () {
      test('Not null', () {
        nullableInterface.nullableObjectProperty = obj;
        expect(nullableInterface.nullableObjectProperty, obj);
      });
      test('Null', () {
        nullableInterface.nullableObjectProperty = null;
        expect(nullableInterface.nullableObjectProperty, null);
      });
    });

    group('Nullable return', () {
      test('Not null', () {
        expect(NullableInterface.returnNil_(lib, false), isA<NSObject>());
      });
      test('Null', () {
        expect(NullableInterface.returnNil_(lib, true), null);
      });
    }, skip: "TODO(#334): enable this test");

    group('Nullable arguments', () {
      test('Not null', () {
        expect(
            NullableInterface.isNullWithNullableNSObjectArg_(lib, obj), false);
      });
      test('Null', () {
        expect(
            NullableInterface.isNullWithNullableNSObjectArg_(lib, null), true);
      });
    });

    group('Not-nullable arguments', () {
      test('Not null', () {
        expect(NullableInterface.isNullWithNotNullableNSObjectPtrArg_(lib, obj),
            false);
      });
    });
  });
}
