// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

void main() {
  group('exclude_all_by_default', () {
    test('exclude_all_by_default test flag false', () {
      final config = Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'exclude_all_by_default test'
${strings.output}: 'unused'
${strings.excludeAllByDefault}: false
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/config_tests/exclude_all_by_default.h'
''') as yaml.YamlMap);

      final library = parse(config);
      expect(library.getBinding('func'), isA<Func>());
      expect(library.getBinding('Struct'), isA<Struct>());
      expect(library.getBinding('Union'), isA<Union>());
      expect(library.getBinding('global'), isA<Global>());
      expect(library.getBinding('MACRO'), isA<Constant>());
      expect(library.getBinding('Enum'), isA<EnumClass>());
      expect(library.getBinding('unnamedEnum'), isA<Constant>());
    });

    test('exclude_all_by_default test flag true', () {
      final config = Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'exclude_all_by_default test'
${strings.output}: 'unused'
${strings.excludeAllByDefault}: true
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/config_tests/exclude_all_by_default.h'
''') as yaml.YamlMap);

      final library = parse(config);
      expect(() => library.getBinding('func'), throwsException);
      expect(() => library.getBinding('Struct'), throwsException);
      expect(() => library.getBinding('Union'), throwsException);
      expect(() => library.getBinding('global'), throwsException);
      expect(() => library.getBinding('MACRO'), throwsException);
      expect(() => library.getBinding('Enum'), throwsException);
      expect(() => library.getBinding('unnamedEnum'), throwsException);
    });
  });
}
