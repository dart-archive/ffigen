// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import './test_utils.dart';

const usage = r'''Regenerates the Dart FFI bindings used in tests and examples.

Use this command when developing features that change the generated bindings
e.g. with this command:

$ dart run test/setup.dart && dart run test/regen.dart && dart test
''';

Future<void> _regenConfig(File yamlConfig, File bindingOutput) async {
  yamlConfig = yamlConfig.absolute;
  bindingOutput = bindingOutput.absolute;
  final config = testConfigFromPath(yamlConfig.path);
  final library = parse(config);
  library.generateFile(bindingOutput);
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

  final nativeTestConfig = File('test/native_test/config.yaml').absolute;
  final nativeTestOut =
      File('test/native_test/native_test_bindings.dart').absolute;
  await withChDir(nativeTestConfig.path,
      () => _regenConfig(nativeTestConfig, nativeTestOut));

  final libclangConfig = File('example/libclang-example/config.yaml').absolute;
  final libclangOut =
      File('example/libclang-example/generated_bindings.dart').absolute;
  await withChDir(
      libclangConfig.path, () => _regenConfig(libclangConfig, libclangOut));

  final simpleConfig = File('example/simple/config.yaml').absolute;
  final simpleOut = File('example/simple/generated_bindings.dart').absolute;
  await withChDir(
      simpleConfig.path, () => _regenConfig(simpleConfig, simpleOut));

  final cJsonConfig = File('example/c_json/config.yaml').absolute;
  final cJsonOut =
      File('example/c_json/cjson_generated_bindings.dart').absolute;
  await withChDir(cJsonConfig.path, () => _regenConfig(cJsonConfig, cJsonOut));
}
