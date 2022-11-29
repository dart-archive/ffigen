// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('simple_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('simple', () {
      final config = testConfig('''
${strings.name}: NativeLibrary
${strings.description}: Bindings to `headers/example.h`.
${strings.output}: 'generated_bindings.dart'
${strings.headers}:
  ${strings.entryPoints}:
    - 'example/simple/headers/example.h'
''');
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        'example_simple.dart',
        ['example', 'simple', config.output],
      );
    });
  });
}
