// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:test/test.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as path;

import '../test_utils.dart';

void main() {
  group('large_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
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
        final expected = File(path.join('test', 'large_integration_tests',
                '_expected_libclang_bindings.dart'))
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

    test('CJSON test', () {
      final config = Config.fromYaml(loadYaml('''
${strings.name}: CJson
${strings.description}: Bindings to Cjson.
${strings.output}: unused
${strings.comments}: full
${strings.libclang_dylib_folder}: tool/wrapped_libclang
${strings.arrayWorkaround}: true
${strings.headers}:
  - third_party/cjson_library/cJSON.h
${strings.headerFilter}:
  include:
    - 'cJSON.h'
      ''') as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'large_test_cjson.dart'),
      );
      library.generateFile(file);

      try {
        final actual = file.readAsStringSync();
        final expected = File(path.join('test', 'large_integration_tests',
                '_expected_cjson_bindings.dart'))
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

    test('SQLite test', () {
      // Excluding functions that use 'va_list' because it can either be a
      // Pointer<__va_list_tag> or int depending on the OS.
      final config = Config.fromYaml(loadYaml('''
${strings.name}: SQLite
${strings.description}: Bindings to SQLite.
${strings.output}: unused
${strings.libclang_dylib_folder}: tool/wrapped_libclang
${strings.arrayWorkaround}: true
${strings.comments}: full
${strings.headers}:
  - third_party/sqlite/sqlite3.h
${strings.headerFilter}:
  ${strings.include}:
    - 'sqlite3.h'
${strings.functions}:
  ${strings.exclude}:
    ${strings.names}:
      - sqlite3_vmprintf
      - sqlite3_vsnprintf
      - sqlite3_str_vappendf
      ''') as YamlMap);
      final library = parse(config);
      final file = File(
        path.join('test', 'debug_generated', 'large_test_sqlite.dart'),
      );
      library.generateFile(file);

      try {
        final actual = file.readAsStringSync();
        final expected = File(path.join('test', 'large_integration_tests',
                '_expected_sqlite_bindings.dart'))
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
