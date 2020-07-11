// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/header_parser.dart';
import 'package:yaml/yaml.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:test/test.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as path;

void main() {
  group('large_test', () {
    test('Libclang test', () {
      final config = Config.fromYaml(loadYaml('''
${strings.name}: LibClang
${strings.description}: Bindings to LibClang.
${strings.output}: unused
${strings.libclang_dylib_folder}: tool/wrapped_libclang
${strings.compilerOpts}: -I${path.join('third_party', 'libclang', 'include')}
${strings.arrayWorkaround}: true
${strings.headers}:
  - third_party/libclang/include/clang-c/Index.h
${strings.headerFilter}:
  include:
    - 'BuildSystem.h'
    - 'CXCompilationDatabase.h'
    - 'CXErrorCode.h'
    - 'CXString.h'
    - 'Documentation.h'
    - 'FataErrorHandler.h'
    - 'Index.h'
      ''') as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'large_test_libclang.dart'),
      );
      library.generateFile(file);

      try {
        final actual = file.readAsStringSync();
        final expected = File(path.join(
                'third_party', 'libclang', 'expected_libclang_bindings.dart'))
            .readAsStringSync();
        expect(actual, expected);
        if (file.existsSync()) {
          file.delete();
        }
      } catch (e) {
        print('Failed test: Debug generated file: ${file.absolute?.path}');
        rethrow;
      }
    });
  });
}
