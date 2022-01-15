// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual, expected;

void main() {
  var logString = '';
  group('unknown_keys_warn_test', () {
    setUpAll(() {
      final logArr = <String>[];
      logWarningsToArray(logArr, Level.WARNING);
      Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Warn for unknown keys.'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/packed_structs.h'
'warn-1': 'warn'
${strings.typeMap}:
  'warn-2': 'warn'
  'warn-3': 'warn'
${strings.functions}:
  'warn-4': 'skip'
${strings.structs}:
  'warn-5': 'skip'
${strings.unions}:
  'warn-6': 'skip'
        ''') as yaml.YamlMap);
      logString = logArr.join("\n");
    });
    test('Warn for unknown keys.', () {
      expect(logString.contains('warn-1'), true);
      expect(logString.contains('warn-2'), true);
      expect(logString.contains('warn-3'), true);
    });
    test('Do not warn for unknown keys in declarations.', () {
      expect(logString.contains('warn-4'), false);
      expect(logString.contains('warn-5'), false);
      expect(logString.contains('warn-6'), false);
    });
  });
}
