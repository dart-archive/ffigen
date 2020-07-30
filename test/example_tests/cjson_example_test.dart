// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('cjson_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('c_json', () {
      final config = Config.fromYaml(loadYaml('''
${strings.output}: 'cjson_generated_bindings.dart'
${strings.name}: 'CJson'
${strings.description}: 'Holds bindings to cJSON.'
${strings.headers}:
  ${strings.entryPoints}:
    - 'third_party/cjson_library/cJSON.h'
  ${strings.includeDirectives}:
    - '**cJSON.h'
${strings.comments}: false
''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'c_json.dart'],
        ['example', 'c_json', config.output],
      );
    });
  });
}
