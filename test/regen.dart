// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'test_utils.dart';

const usage = r'''Regenerates the Dart FFI bindings used in tests and examples.

Use this command when developing features that change the generated bindings
e.g. with this command:

$ dart run test/setup.dart && dart run test/regen.dart && dart test
''';

void _regenConfig(String yamlConfigPath, String bindingOutputPath) {
  final yamlConfig = File(yamlConfigPath).absolute;
  final bindingOutput = File(bindingOutputPath).absolute;
  withChDir(yamlConfig.path, () {
    final config = testConfigFromPath(yamlConfig.path);
    final library = parse(config);
    library.generateFile(bindingOutput);
  });
}

Future<void> main(List<String> args) async {
  final parser = ArgParser();
  parser.addSeparator(usage);
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'Prints this usage',
    negatable: false,
  );

  final parseArgs = parser.parse(args);
  if (parseArgs.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  } else if (parseArgs.rest.isNotEmpty) {
    print(parser.usage);
    exit(1);
  }

  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _regenConfig('test/native_test/config.yaml',
      'test/native_test/_expected_native_test_bindings.dart');
  _regenConfig('example/libclang-example/config.yaml',
      'example/libclang-example/generated_bindings.dart');
  _regenConfig(
      'example/simple/config.yaml', 'example/simple/generated_bindings.dart');
  _regenConfig('example/c_json/config.yaml',
      'example/c_json/cjson_generated_bindings.dart');
}
