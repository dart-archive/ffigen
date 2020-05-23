// Executable script to be called by user to generate bindings for some C library
import 'dart:io';

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/print.dart';

import 'package:yaml/yaml.dart' as yaml;

void main(List<String> args) {
  Config config;

  printVerbose("Cmd args: $args");
  if (args.length > 1) {
    printError("Error: Expected less than or equal to 1 command line arguments");
    exit(1);
  } else if (args.length == 1) {
    config = getConfigFromCustomYaml(args[0]);
  } else {
    config = getConfigFromPubspec();
  }
  //TODO: debug print, delete later
  printExtraVerbose('Config: ' + config.toString());

  final library = parser.parse(config);

  File gen = File('gen.dart');

  //TODO: give sort option to user
  library.sort();
  library.generateFile(gen);
  printInfo('Finished, Bindings generated in ${gen?.absolute?.path}');
}

Config getConfigFromPubspec() {
  var currentDir = Directory.current;
  printInfo('Running in ${currentDir}');

  var pubspecName = 'pubspec.yaml';
  var configKey = 'ffigen';

  var pubspecFile = File(pubspecName);

  if (!pubspecFile.existsSync()) {
    printError(
        'Error: $pubspecName not found, please run this tool from the root of your package');
    exit(1);
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // can throw YamlException() if unable to parse
  var bindingsConfigMap =
      yaml.loadYaml(pubspecFile.readAsStringSync())[configKey] as yaml.YamlMap;

  if (bindingsConfigMap == null) {
    printError("Couldn't find an entry for $configKey in pubspec.yaml");
    exit(1);
  }
  return Config.fromYaml(bindingsConfigMap);
}

Config getConfigFromCustomYaml(String yamlPath) {
  var currentDir = Directory.current;
  printInfo('Running in ${currentDir}');

  var yamlFile = File(yamlPath);

  if (!yamlFile.existsSync()) {
    printError(
        'Error: $yamlPath not found, please run this tool from the root of your package');
    exit(1);
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // can throw YamlException() if unable to parse
  var bindingsConfigMap =
      yaml.loadYaml(yamlFile.readAsStringSync()) as yaml.YamlMap;

  return Config.fromYaml(bindingsConfigMap);
}
