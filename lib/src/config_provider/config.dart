import '../strings.dart' as string;
import 'header.dart';
import 'package:yaml/yaml.dart';

/// Holds all configurations.
class Config {
  dynamic _raw;

  /// libclang path
  String libclang_dylib_path;

  /// path to headers
  final List<Header> headers;

  /// [ffigenMap] has required configurations
  Config.fromYaml(YamlMap ffigenMap) : headers = [] {
    _raw = ffigenMap;

    libclang_dylib_path = ffigenMap[string.libclang_dylib] as String;

    for (var header in (ffigenMap[string.headers] as YamlList)) {
      headers.add(Header(header as String));
    }
  }

  /// Use `Config.fromYaml` if extracting info from yaml file
  Config({this.libclang_dylib_path, this.headers});

  @override
  String toString() {
    return _raw != null ? _raw.toString() : 'Instance of `${runtimeType}`';
  }
}
