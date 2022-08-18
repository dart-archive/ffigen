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
  group('ffinative_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('ffinative', () {
      final config = Config.fromYaml(loadYaml('''
${strings.name}: NativeLibrary
${strings.ffiNative}:
${strings.description}: Bindings to `headers/example.h`.
${strings.output}: 'generated_bindings.dart'
${strings.headers}:
  ${strings.entryPoints}:
    - 'example/ffinative/headers/example.h'
''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'example_ffinative.dart'],
        ['example', 'ffinative', config.output],
      );
    });
  });
}
