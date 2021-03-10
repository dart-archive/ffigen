// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/spec_utils.dart';
import 'package:test/test.dart';

late Library actual, expected;

void main() {
  group('compiler_opts_test', () {
    test('Compiler Opts', () {
      final opts =
          '''--option value "in double quotes" 'in single quotes'  -tab=separated''';
      final list = compilerOptsToList(opts);
      expect(
        list,
        <String>[
          '--option',
          'value',
          'in double quotes',
          'in single quotes',
          '-tab=separated',
        ],
      );
    });
  });
}
