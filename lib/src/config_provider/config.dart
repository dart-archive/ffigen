import '../strings.dart';
import 'package:yaml/yaml.dart';

/// Holds all configurations.
class Config {
  dynamic _raw;
  String libclang_dylib_path;

  /// [yamlMap] has required configurations
  Config.fromYaml(YamlMap yamlMap) {
    _raw = yamlMap;
    libclang_dylib_path = yamlMap[ConfigKeys.libclang_dylib] as String;
  }

  @override
  String toString() {
    return _raw.toString();
  }
}
