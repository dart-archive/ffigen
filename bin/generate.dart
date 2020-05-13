// Executable script to be called by user to generate bindings for some C library
import 'dart:io';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:yaml/yaml.dart' as yaml;

void main() {
  var currentDir = Directory.current;
  print('Running in ${currentDir}');

  var pubspecName = 'pubspec.yaml';
  var configKey = 'ffigen';

  var pubspecFile = File(pubspecName);
  yaml.YamlMap bindingsConfigMap;

  if (!pubspecFile.existsSync()) {
    print(
        'Error: $pubspecName not found, please run this tool from the root of your package');
    exit(1);
  }

  try {
    // Casting this because pubspec is expected to be a YamlMap.
    bindingsConfigMap = yaml.loadYaml(pubspecFile.readAsStringSync())[configKey]
        as yaml.YamlMap;

    if (bindingsConfigMap == null) {
      print("Couldn't find an entry for $configKey in pubspec.yaml");
      exit(2);
    }
  } catch (e) {
    print(e);
    exit(3);
  }
  var config = Config.fromYaml(bindingsConfigMap);
}
