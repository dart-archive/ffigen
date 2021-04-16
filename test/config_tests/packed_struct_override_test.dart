// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:yaml/yaml.dart' as yaml;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  group('packed_struct_override_test', () {
    test('Invalid Packed Config values', () {
      const baseYaml = '''${strings.name}: 'NativeLibrary'
${strings.description}: 'Packed Struct Override Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/packed_structs.h'
${strings.structs}:
  ${strings.structPack}:
    ''';
      expect(
          () => Config.fromYaml(
              yaml.loadYaml(baseYaml + "'.*': null") as yaml.YamlMap),
          throwsA(TypeMatcher<FormatException>()));
      expect(
          () => Config.fromYaml(
              yaml.loadYaml(baseYaml + "'.*': 3") as yaml.YamlMap),
          throwsA(TypeMatcher<FormatException>()));
      expect(
          () => Config.fromYaml(
              yaml.loadYaml(baseYaml + "'.*': 32") as yaml.YamlMap),
          throwsA(TypeMatcher<FormatException>()));
    });
    test('Override values', () {
      final config = Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Packed Struct Override Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/packed_structs.h'
${strings.structs}:
  ${strings.structPack}:
    'Normal.*': 1
    'StructWithAttr': 2
    'PackedAttr': none
        ''') as yaml.YamlMap);

      final library = parse(config);

      expect((library.getBinding('NormalStruct1') as Struc).pack, 1);
      expect((library.getBinding('StructWithAttr') as Struc).pack, 2);
      expect((library.getBinding('PackedAttr') as Struc).pack, null);
    });
  });
}
