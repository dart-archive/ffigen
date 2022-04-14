// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

const usage = r'''Regenerates the Dart FFI bindings used in tests and examples.

Use this command when developing features that change the generated bindings
e.g. with this command:

$ dart run test/setup.dart && dart run test/regen.dart && dart test
''';

Future<void> _regenConfig(File yamlConfig, File bindingOutput,
    {bool chDir = false}) async {
  yamlConfig = yamlConfig.absolute;
  bindingOutput = bindingOutput.absolute;

  Directory? oldDir;
  var yaml = loadYaml(await yamlConfig.readAsString()) as YamlMap;

  if (chDir) {
    oldDir = Directory.current;
    Directory.current = yamlConfig.parent;
  }
  try {
    if (yaml.containsKey("ffigen")) {
      yaml = yaml["ffigen"] as YamlMap;
    }

    final config = Config.fromYaml(yaml);
    final library = parse(config);
    library.generateFile(bindingOutput);
  } finally {
    if (oldDir != null) {
      Directory.current = oldDir;
    }
  }
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

  await _regenConfig(
    File('test/native_objc_test/config.yaml'),
    File('test/native_objc_test/native_objc_test_bindings.dart'),
  );

  await _regenConfig(File('test/native_test/config.yaml'),
      File('test/native_test/native_test_bindings.dart'));

  await _regenConfig(File('example/libclang-example/pubspec.yaml'),
      File('example/libclang-example/generated_bindings.dart'),
      chDir: true);

  await _regenConfig(File('example/simple/pubspec.yaml'),
      File('example/simple/generated_bindings.dart'),
      chDir: true);

  await _regenConfig(File('example/c_json/pubspec.yaml'),
      File('example/c_json/cjson_generated_bindings.dart'),
      chDir: true);
}
