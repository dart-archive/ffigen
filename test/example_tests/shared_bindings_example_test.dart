// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('shared_bindings_example', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('a_shared_base bindings', () {
      final config = testConfigFromPath(path.join(
        'example',
        'shared_bindings',
        'ffigen_configs',
        'a_shared_base.yaml',
      ));
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        'example_shared_bindings.dart',
        [config.output],
      );
    });

    test('base symbol file output', () {
      final config = testConfigFromPath(path.join(
        'example',
        'shared_bindings',
        'ffigen_configs',
        'base.yaml',
      ));
      final library = parse(config);
      matchLibrarySymbolFileWithExpected(
        library,
        'example_shared_bindings.yaml',
        [config.symbolFile!.output],
        config.symbolFile!.importPath,
      );
    });
  });
}
