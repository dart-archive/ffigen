// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
${strings.compilerOpts}: -I${path.join('third_party', 'libclang', 'include')}
${strings.arrayWorkaround}: true
${strings.comments}:
  ${strings.style}: ${strings.doxygen}
  ${strings.length}: ${strings.brief}
${strings.headers}:
  ${strings.entryPoints}:
    - third_party/libclang/include/clang-c/Index.h
  ${strings.includeDirectives}:
    - '**BuildSystem.h'
    - '**CXCompilationDatabase.h'
    - '**CXErrorCode.h'
    - '**CXString.h'
    - '**Documentation.h'
    - '**FataErrorHandler.h'
    - '**Index.h'
      ''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'large_test_libclang.dart'],
        ['test', 'large_integration_tests', '_expected_libclang_bindings.dart'],
      );
    });

    test('CJSON test', () {
      final config = Config.fromYaml(loadYaml('''
${strings.name}: CJson
${strings.description}: Bindings to Cjson.
${strings.output}: unused
${strings.comments}:
  ${strings.length}: ${strings.full}
${strings.arrayWorkaround}: true
${strings.headers}:
  ${strings.entryPoints}:
    - third_party/cjson_library/cJSON.h
  ${strings.includeDirectives}:
    - '**cJSON.h'
      ''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'large_test_cjson.dart'],
        ['test', 'large_integration_tests', '_expected_cjson_bindings.dart'],
      );
    });

    test('SQLite test', () {
      // Excluding functions that use 'va_list' because it can either be a
      // Pointer<__va_list_tag> or int depending on the OS.
      final config = Config.fromYaml(loadYaml('''
${strings.name}: SQLite
${strings.description}: Bindings to SQLite.
${strings.output}: unused
${strings.arrayWorkaround}: true
${strings.comments}:
  ${strings.style}: ${strings.any}
  ${strings.length}: ${strings.full}
${strings.headers}:
  ${strings.entryPoints}:
    - third_party/sqlite/sqlite3.h
  ${strings.includeDirectives}:
    - '**sqlite3.h'
${strings.functions}:
  ${strings.exclude}:
    ${strings.names}:
      - sqlite3_vmprintf
      - sqlite3_vsnprintf
      - sqlite3_str_vappendf
      ''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'large_test_sqlite.dart'],
        ['test', 'large_integration_tests', '_expected_sqlite_bindings.dart'],
      );
    });
  });
}
