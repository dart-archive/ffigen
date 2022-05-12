// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
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
  ${strings.exposeFunctionTypedefs}:
      ${strings.include}:
        - 'clang_.*'
${strings.structs}:
  ${strings.include}:
      - 'CX.*'
${strings.enums}:
  ${strings.include}:
    - 'CXTypeKind'
    - 'CXGlobalOptFlags'
${strings.libraryImports}:
  custom_import: 'custom_import.dart'
${strings.typeMap}:
  ${strings.typeMapTypedefs}:
    'size_t':
      lib: 'pkg_ffi'
      c-type: 'Size'
      dart-type: 'int'
    'time_t':
      lib: 'ffi'
      c-type: 'Int64'
      dart-type: 'int'
  ${strings.typeMapNativeTypes}:
    'unsigned long':
      lib: 'custom_import'
      c-type: 'UnsignedLong'
      dart-type: 'int'
  ${strings.typeMapStructs}:
    'CXCursorSetImpl':
      lib: 'custom_import'
      c-type: 'CXCursorSetImpl'
      dart-type: 'CXCursorSetImpl'
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

  // ignore_for_file: camel_case_types, non_constant_identifier_names
''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'example_libclang.dart'],
        ['example', 'libclang-example', config.output],
      );
    });
  });
}
