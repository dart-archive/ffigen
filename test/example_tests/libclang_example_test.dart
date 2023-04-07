// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator/library.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('libclang-example', () {
      final configYaml =
          File(path.join('example', 'libclang-example', 'config.yaml'))
              .absolute;
      late Config config;
      late Library library;
      withChDir(configYaml.path, () {
        config = testConfigFromPath(configYaml.path);
        library = parse(config);
      });

      matchLibraryWithExpected(
        library,
        'example_libclang.dart',
        [config.output],
      );
    });
  });
}
