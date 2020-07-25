// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/config_provider.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:ffigen/src/strings.dart' as strings;

import '../test_utils.dart';

Library actual, expected;

void main() {
  group('function_n_struct_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      expected = expectedLibrary();
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Function And Struct Test'
${strings.output}: 'unused'

${strings.headers}:
  - 'test/header_parser_tests/function_n_struct.h'
        ''') as yaml.YamlMap),
      );
    });

    test('func1', () {
      expect(actual.getBindingAsString('func1'),
          expected.getBindingAsString('func1'));
    });
    test('Struct2', () {
      expect((actual.getBinding('Struct2') as Struc).members.isEmpty, true);
    });
  });
}

Library expectedLibrary() {
  final struc2 = Struc(name: 'Struct2', members: []);
  return Library(
    name: 'Bindings',
    bindings: [
      struc2,
      Struc(name: 'Struct1', members: [
        Member(
          name: 'a',
          type: Type.nativeType(SupportedNativeType.Int32),
        ),
      ]),
      Func(
        name: 'func1',
        parameters: [
          Parameter(name: 's', type: Type.pointer(Type.struct(struc2))),
        ],
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
    ],
  );
}
