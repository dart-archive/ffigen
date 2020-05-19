import 'dart:io';

import '../strings.dart' as string;
import 'header.dart';
import 'package:yaml/yaml.dart';

import 'input_checker.dart';

/// Holds all configurations.
/// and has methods to convert various configurations
/// to a format requested by submodules
class Config {
  dynamic _raw;

  /// libclang path
  String libclang_dylib_path;

  /// path to headers
  final List<Header> headers;

  /// commandLineArguments to pass to clang_compiler
  List<String> compilerOpts;

  /// [ffigenMap] has required configurations
  Config.fromYaml(YamlMap ffigenMap) : headers = [] {
    var result = checkYaml(ffigenMap);
    if (result == CheckerResult.error) {
      print('Please fix errors in Configurations and re-run the tool');
      exit(1);
    }
    _raw = ffigenMap;

    libclang_dylib_path = ffigenMap[string.libclang_dylib] as String;

    for (var header in (ffigenMap[string.headers] as YamlList)) {
      headers.add(Header(header as String));
    }

    compilerOpts = (ffigenMap[string.compilerOpts] as String)?.split(' ');
  }

  /// Use `Config.fromYaml` if extracting info from yaml file
  Config({this.libclang_dylib_path, this.headers});

  @override
  String toString() {
    return _raw != null ? _raw.toString() : 'Instance of `${runtimeType}`';
  }
}
