// Executable script to be called by user to generate bindings for some C library
import 'dart:io';

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart';

import 'package:yaml/yaml.dart' as yaml;

void main() {
  final config = getConfigFromPubspec();
  //TODO: debug print, delete later
  print('debug: '+config.toString());

  final parser = Parser(config);

  final library = parser.parse();

  library.generateFile(File('gen.dart'));
}

Config getConfigFromPubspec() {
  var currentDir = Directory.current;
  print('Running in ${currentDir}');

  var pubspecName = 'pubspec.yaml';
  var configKey = 'ffigen';

  var pubspecFile = File(pubspecName);

  if (!pubspecFile.existsSync()) {
    throw Exception(
        'Error: $pubspecName not found, please run this tool from the root of your package');
  }

  // Casting this because pubspec is expected to be a YamlMap.

  // can throw YamlException() if unable to parse
  var bindingsConfigMap =
      yaml.loadYaml(pubspecFile.readAsStringSync())[configKey] as yaml.YamlMap;

  if (bindingsConfigMap == null) {
    throw Exception("Couldn't find an entry for $configKey in pubspec.yaml");
  }
  return Config.fromYaml(bindingsConfigMap);
}
