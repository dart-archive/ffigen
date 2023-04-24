// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('include_exclude', () {
    const fieldsAndNameMap = {
      strings.functions: 'func',
      strings.structs: 'Struct',
      strings.unions: 'Union',
      strings.enums: 'Enum',
      strings.unnamedEnums: 'unnamedEnum',
      strings.macros: 'MACRO',
      strings.globals: 'global',
      strings.typedefs: 'Typedef',
    };
    for (final f in fieldsAndNameMap.keys) {
      test('include $f', () {
        final config = _makeFieldIncludeExcludeConfig(
            field: f, include: fieldsAndNameMap[f]);
        final library = parse(config);
        expect(library.getBinding(fieldsAndNameMap[f]!), isNotNull);
      });
      test('exclude $f', () {
        final config = _makeFieldIncludeExcludeConfig(
            field: f, exclude: fieldsAndNameMap[f]);
        final library = parse(config);
        expect(() => library.getBinding(fieldsAndNameMap[f]!), throwsException);
      });
    }
  });
}

Config _makeFieldIncludeExcludeConfig({
  required String field,
  String? include,
  String? exclude,
}) {
  var templateString = '''
${strings.name}: 'NativeLibrary'
${strings.description}: 'include_exclude test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/config_tests/include_exclude.h'
''';
  if (include != null || exclude != null) {
    templateString += '''
$field:
''';
    if (include != null) {
      templateString += '''
  ${strings.include}:
    - $include
''';
    }
    if (exclude != null) {
      templateString += '''
  ${strings.exclude}:
    - $exclude
''';
    }
  }

  final config = testConfig(templateString);
  return config;
}
