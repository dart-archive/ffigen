// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cli_util/cli_util.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('dart_handle_test', () {
    setUpAll(() {
      logWarnings();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Dart_Handle Test'
${strings.output}: 'unused'
${strings.compilerOpts}: '-I${path.join(getSdkPath(), "include")}'

${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/dart_handle.h'
  ${strings.includeDirectives}:
    - '**dart_handle.h'
        ''') as yaml.YamlMap),
      );
    });
    test('Expected Bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_dart_handle_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_dart_handle_bindings.dart'
      ]);
    });
  });
}
