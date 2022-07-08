// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

// Objective C support is only available on mac.
@TestOn('mac-os')
import '../test_utils.dart';

void main() {
  group('objective_c_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('objective_c', () {
      final pubspecFile = File('example/objective_c/pubspec.yaml');
      final pubspecYaml = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
      final config = Config.fromYaml(pubspecYaml['ffigen'] as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'example_objective_c.dart'],
        ['example', 'objective_c', config.output],
      );
    });
  });
}
