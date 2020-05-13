import '../strings.dart';
import 'package:yaml/yaml.dart';

/// Holds all configurations.
class Config {
  String libclang_dylib_path;

  /// [yamlMap] has required configurations
  Config.fromYaml(YamlMap yamlMap) {
    libclang_dylib_path = yamlMap[ConfigKeys.libclang_dylib] as String;
  }
}
