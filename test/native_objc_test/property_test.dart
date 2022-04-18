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
import 'property_bindings.dart';

void main() {
  late PropertyInterface testInstance;
  late PropertyTestObjCLibrary lib;

  group('properties', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/property_test.dylib');
      verifySetupFile(dylib);
      lib = PropertyTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      testInstance = PropertyInterface.new1(lib);
    });

    test('generate_bindings', () {
      final config = Config.fromYaml(loadYaml(
          File(path.join('test', 'native_objc_test', 'property_config.yaml'))
              .readAsStringSync()) as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'property_test.dart'),
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

    group('instance properties', () {
      test('read-only property', () {
        expect(testInstance.readOnlyProperty, 7);
      });

      test('read-write property', () {
        testInstance.readWriteProperty = 23;
        expect(testInstance.readWriteProperty, 23);
      });
    });

    group('class properties', () {
      test('read-only property', () {
        expect(PropertyInterface.getClassReadOnlyProperty(lib), 42);
      });

      test('read-write property', () {
        PropertyInterface.setClassReadWriteProperty(lib, 101);
        expect(PropertyInterface.getClassReadWriteProperty(lib), 101);
      });
    });
  });
}
