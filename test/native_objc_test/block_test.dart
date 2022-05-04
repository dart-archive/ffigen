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
import 'block_bindings.dart';

void main() {
  late BlockTestObjCLibrary lib;

  group('Blocks', () {
    setUpAll(() {
      logWarnings();
      final dylib = File('test/native_objc_test/block_test.dylib');
      verifySetupFile(dylib);
      lib = BlockTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));
    });

    test('generate_bindings', () {
      final config = Config.fromYaml(loadYaml(
          File(path.join('test', 'native_objc_test', 'block_config.yaml'))
              .readAsStringSync()) as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'block_test.dart'),
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

    test('BlockTester is working', () {
      // This doesn't test any Block functionality, just that the BlockTester
      // itself is working correctly.
      final blockTester = BlockTester.makeFromMultiplier_(lib, 10);
      expect(blockTester.call_(123), 1230);
      final intBlock = blockTester.getBlock();
      final blockTester2 = BlockTester.makeFromBlock_(lib, intBlock);
      expect(blockTester2.call_(456), 4560);
    });

    test('Block from function pointer', () {
      final block = ObjCBlock.fromFunctionPointer(
          lib, Pointer.fromFunction(_add100, 999));
      final blockTester = BlockTester.makeFromBlock_(lib, block.pointer);
      expect(blockTester.call_(123), 223);
    });
  });
}

int _add100(int x) {
  return x + 100;
}
