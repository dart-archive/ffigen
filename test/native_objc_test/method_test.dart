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
import 'method_bindings.dart';

void main() {
  late MethodInterface testInstance;
  late MethodTestObjCLibrary lib;

  group('method calls', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/method_test.dylib');
      verifySetupFile(dylib);
      lib = MethodTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
      testInstance = MethodInterface.new1(lib);
    });

    test('generate_bindings', () {
      final config = Config.fromYaml(loadYaml(
          File(path.join('test', 'native_objc_test', 'method_config.yaml'))
              .readAsStringSync()) as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'method_test.dart'),
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

    group('Instance methods', () {
      test('No arguments', () {
        expect(testInstance.add(), 5);
      });

      test('One argument', () {
        expect(testInstance.add_(23), 23);
      });

      test('Two arguments', () {
        expect(testInstance.add_Y_(23, 17), 40);
      });

      test('Three arguments', () {
        expect(testInstance.add_Y_Z_(23, 17, 60), 100);
      });
    });

    group('Class methods', () {
      test('No arguments', () {
        expect(MethodInterface.sub(lib), -5);
      });

      test('One argument', () {
        expect(MethodInterface.sub_(lib, 7), -7);
      });

      test('Two arguments', () {
        expect(MethodInterface.sub_Y_(lib, 7, 3), -10);
      });

      test('Three arguments', () {
        expect(MethodInterface.sub_Y_Z_(lib, 10, 7, 3), -20);
      });
    });
  });
}
