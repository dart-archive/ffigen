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
import 'forward_decl_bindings.dart';

void main() {
  late ForwardDeclTestObjCLibrary lib;

  group('forward decl', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/forward_decl_test.dylib');
      verifySetupFile(dylib);
      lib =
          ForwardDeclTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
    });

    test('generate_bindings', () {
      final config = Config.fromYaml(loadYaml(File(
              path.join('test', 'native_objc_test', 'forward_decl_config.yaml'))
          .readAsStringSync()) as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'forward_decl_test.dart'),
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

    test('Forward declared class', () {
      expect(ForwardDeclaredClass.get123(lib), 123);
    });
  });
}
