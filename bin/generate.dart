// Executable script to be called by user to generate bindings for some C library
import 'dart:io';

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;

import 'package:yaml/yaml.dart' as yaml;

void main(List<String> args) {
  Config config;

  print(args);
  if (args.length > 1) {
    print("Error: Expected less than or equal to 1 command line arguments");
    exit(1);
  } else if (args.length == 1) {
    config = getConfigFromCustomYaml(args[0]);
  } else {
    config = getConfigFromPubspec();
  }
  //TODO: debug print, delete later
  print('debug: ' + config.toString());

  final library = parser.parse(config);

  File gen = File('gen.dart');
  library.generateFile(gen);
  print('Finished, Bindings generated in ${gen?.absolute?.path}');
}

Config getConfigFromPubspec() {
  var currentDir = Directory.current;
  print('Running in ${currentDir}');

  var pubspecName = 'pubspec.yaml';
  var configKey = 'ffigen';

  var pubspecFile = File(pubspecName);

  if (!pubspecFile.existsSync()) {
    print(
        'Error: $pubspecName not found, please run this tool from the root of your package');
    exit(1);
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // can throw YamlException() if unable to parse
  var bindingsConfigMap =
      yaml.loadYaml(pubspecFile.readAsStringSync())[configKey] as yaml.YamlMap;

  if (bindingsConfigMap == null) {
    print("Couldn't find an entry for $configKey in pubspec.yaml");
    exit(1);
  }
  return Config.fromYaml(bindingsConfigMap);
}

Config getConfigFromCustomYaml(String yamlPath) {
  var currentDir = Directory.current;
  print('Running in ${currentDir}');

  var yamlFile = File(yamlPath);

  if (!yamlFile.existsSync()) {
    print(
        'Error: $yamlPath not found, please run this tool from the root of your package');
    exit(1);
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // can throw YamlException() if unable to parse
  var bindingsConfigMap =
      yaml.loadYaml(yamlFile.readAsStringSync()) as yaml.YamlMap;

  return Config.fromYaml(bindingsConfigMap);
}
