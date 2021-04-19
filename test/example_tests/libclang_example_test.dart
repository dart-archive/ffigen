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
  group('example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('libclang-example', () {
      final config = Config.fromYaml(loadYaml('''
${strings.output}: 'generated_bindings.dart'
${strings.headers}:
  ${strings.entryPoints}:
    - third_party/libclang/include/clang-c/Index.h
  ${strings.includeDirectives}:
    - '**CXString.h'
    - '**Index.h'

${strings.compilerOpts}: '-Ithird_party/libclang/include -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ -Wno-nullability-completeness'
${strings.functions}:
  ${strings.include}:
    - 'clang_.*'
  ${strings.symbolAddress}:
      ${strings.include}:
        - 'clang_.*'
${strings.structs}:
  ${strings.include}:
      - 'CX.*'
${strings.enums}:
  ${strings.include}:
    - 'CXTypeKind'
    - 'CXGlobalOptFlags'

${strings.name}: 'LibClang'
${strings.description}: 'Holds bindings to LibClang.'
${strings.comments}:
  ${strings.style}: ${strings.doxygen}
  ${strings.length}: ${strings.full}

${strings.preamble}: |
  // Part of the LLVM Project, under the Apache License v2.0 with LLVM
  // Exceptions.
  // See https://llvm.org/LICENSE.txt for license information.
  // SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'libclang-example.dart'],
        ['example', 'libclang-example', config.output],
      );
    });
  });
}
