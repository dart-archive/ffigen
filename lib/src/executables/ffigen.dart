// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Executable script to generate bindings for some C library.
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'package:ffigen/src/executables/setup.dart';

final _logger = Logger('ffigen.ffigen');
final _ansi = Ansi(Ansi.terminalSupportsAnsi);

String successPen(String str) {
  return '${_ansi.green}$str${_ansi.none}';
}

String errorPen(String str) {
  return '${_ansi.red}$str${_ansi.none}';
}

void main(List<String> args) {
  // Parses the cmd args. This will print usage and exit if --help was passed.
  final argResult = getArgResults(args);

  // Setup logging level and printing.
  setupLogger(argResult);

  /// Prompt user if dylib doesn't exist and cannot be auto created to run
  /// `pub run ffigen:setup -Ipath/to/llvm/include -Lpath/to/llvm/lib`.
  if (!checkDylibExist() && !autoCreateDylib()) {
    _logger.severe('Unable to create dynamic library automatically.');
    _logger.severe('If LLVM (9+) is installed, try running:');
    _logger.severe(
        '  pub run ffigen:setup -Ipath/to/llvm/include -Lpath/to/llvm/lib');
    exit(1);
  }

  // Create a config object.
  Config config;
  try {
    config = getConfig(argResult);
  } on FormatException {
    _logger.severe('Please fix configuration errors and re-run the tool.');
    exit(1);
  }

  // Parse the bindings according to config object provided.
  final library = parse(config);

  // Generate file for the parsed bindings.
  final gen = File(config.output);
  library.generateFile(gen);
  _logger
      .info(successPen('Finished, Bindings generated in ${gen.absolute.path}'));
}

Config getConfig(ArgResults result) {
  _logger.info('Running in ${Directory.current}');

  if (result.wasParsed('config')) {
    return getConfigFromCustomYaml(result['config'] as String);
  } else {
    return getConfigFromPubspec();
  }
}

/// Extracts configuration from pubspec file.
Config getConfigFromPubspec() {
  final pubspecName = 'pubspec.yaml';
  final configKey = 'ffigen';

  final pubspecFile = File(pubspecName);

  if (!pubspecFile.existsSync()) {
    _logger.severe(
        'Error: $pubspecName not found, please run this tool from the root of your package.');
    exit(1);
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // Throws a [YamlException] if it's unable to parse the Yaml.
  final bindingsConfigMap =
      yaml.loadYaml(pubspecFile.readAsStringSync())[configKey] as yaml.YamlMap?;

  if (bindingsConfigMap == null) {
    _logger.severe("Couldn't find an entry for '$configKey' in $pubspecName.");
    exit(1);
  }
  return Config.fromYaml(bindingsConfigMap);
}

/// Extracts configuration from a custom yaml file.
Config getConfigFromCustomYaml(String yamlPath) {
  final yamlFile = File(yamlPath);

  if (!yamlFile.existsSync()) {
    _logger.severe('Error: $yamlPath not found.');
    exit(1);
  }

  // Throws a [YamlException] if it's unable to parse the Yaml.
  final bindingsConfigMap =
      yaml.loadYaml(yamlFile.readAsStringSync()) as yaml.YamlMap;

  return Config.fromYaml(bindingsConfigMap);
}

/// Parses the cmd line arguments.
ArgResults getArgResults(List<String> args) {
  final parser = ArgParser(allowTrailingOptions: true);

  parser.addSeparator(
      'FFIGEN: Generate dart bindings from C header files\nUsage:');
  parser.addOption(
    'config',
    help: 'path to Yaml file containing configurations if not in pubspec.yaml',
  );
  parser.addOption(
    'verbose',
    abbr: 'v',
    defaultsTo: 'info',
    allowed: [
      'all',
      'fine',
      'info',
      'warning',
      'severe',
    ],
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'prints this usage',
    negatable: false,
  );

  ArgResults results;
  try {
    results = parser.parse(args);

    if (results.wasParsed('help')) {
      print(parser.usage);
      exit(0);
    }
  } catch (e) {
    print(e);
    print(parser.usage);
    exit(1);
  }

  return results;
}

/// Sets up the logging level and printing.
void setupLogger(ArgResults result) {
  if (result.wasParsed('verbose')) {
    switch (result['verbose'] as String?) {
      case 'all':
        // Logs everything, the entire AST touched by our parser.
        Logger.root.level = Level.ALL;
        break;
      case 'fine':
        // Logs AST parts relevant to user (i.e those included in filters).
        Logger.root.level = Level.FINE;
        break;
      case 'info':
        // Logs relevant info for general user (default).
        Logger.root.level = Level.INFO;
        break;
      case 'warning':
        // Logs warnings for relevant stuff.
        Logger.root.level = Level.WARNING;
        break;
      case 'severe':
        // Logs severe warnings and errors.
        Logger.root.level = Level.SEVERE;
        break;
    }
    // Setup logger for printing (if verbosity was set by user).
    Logger.root.onRecord.listen((record) {
      final level = '[${record.level.name}]'.padRight(9);
      printLog('${level}: ${record.message}', record.level);
    });
  } else {
    // Setup logger for printing (if verbosity was not set by user).
    Logger.root.onRecord.listen((record) {
      if (record.level.value > Level.INFO.value) {
        final level = '[${record.level.name}]'.padRight(9);
        printLog('${level}: ${record.message}', record.level);
      } else {
        printLog(record.message, record.level);
      }
    });
  }
}

void printLog(String log, Level level) {
  // Prints text in red for Severe logs only.
  if (level < Level.SEVERE) {
    print(log);
  } else {
    print(errorPen(log));
  }
}
