// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_utils.dart';

void main() {
  group('shared_bindings_example', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('a_shared_base bindings', () {
      final config = Config.fromYaml(loadYaml('''
${strings.name}: NativeLibraryASharedB
${strings.description}: Bindings to `headers/a.h` with shared definitions from `headers/base.h`.
${strings.output}: 'lib/generated/a_shared_b_gen.dart'
${strings.headers}:
  ${strings.entryPoints}:
    - 'example/shared_bindings/headers/a.h'
${strings.import}:
  ${strings.symbolFilesImport}:
    - 'example/shared_bindings/lib/generated/base_symbols.yaml'
${strings.preamble}: |
  // ignore_for_file: non_constant_identifier_names, camel_case_types
''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        'example_shared_bindings.dart',
        ['example', 'shared_bindings', config.output],
      );
    });

    test('base symbol file output', () {
      final config = Config.fromYaml(loadYaml('''
${strings.name}: NativeLibraryBase
${strings.description}: Bindings to `headers/base.h`.
${strings.output}:
  ${strings.bindings}: 'lib/generated/base_gen.dart'
  ${strings.symbolFile}:
    ${strings.output}: 'lib/generated/base_symbols.yaml'
    ${strings.importPath}: 'package:shared_bindings/generated/base_gen.dart'
${strings.headers}:
  ${strings.entryPoints}:
    - 'example/shared_bindings/headers/base.h'
${strings.preamble}: |
  // ignore_for_file: non_constant_identifier_names, camel_case_types
''') as YamlMap);
      final library = parse(config);
      matchLibrarySymbolFileWithExpected(
        library,
        'example_shared_bindings.yaml',
        ['example', 'shared_bindings', config.symbolFile!.output],
        config.symbolFile!.importPath,
      );
    });
  });
}
