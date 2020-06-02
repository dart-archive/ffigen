import 'dart:io';

import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import 'filter.dart';
import 'header.dart';
import 'input_checker.dart';
import '../strings.dart' as string;

var _logger = Logger('config_provider');

/// Holds all configurations.
/// and has methods to convert various configurations
/// to a format requested by submodules
class Config {
  dynamic _raw;

  /// output file name
  String output;

  /// libclang path
  String libclang_dylib_path;

  /// path to headers
  final List<Header> headers;

  final Set<String> includedInclusionHeaders;
  final Set<String> excludedInclusionHeaders;

  /// commandLineArguments to pass to clang_compiler
  List<String> compilerOpts;

  // Filter for functions
  Filter functionFilters;

  // Filter for structs
  Filter structFilters;

  // Filter for enumClass
  Filter enumClassFilters;

  /// [ffigenMap] has required configurations
  Config.fromYaml(YamlMap ffigenMap)
      : headers = [],
        includedInclusionHeaders = {},
        excludedInclusionHeaders = {} {
    var result = checkYaml(ffigenMap);
    if (result == CheckerResult.error) {
      _logger.severe('Please fix errors in Configurations and re-run the tool');
      exit(1);
    }
    _raw = ffigenMap;

    output = ffigenMap[string.output] as String;

    libclang_dylib_path = ffigenMap[string.libclang_dylib] as String;

    // Adding headers from Yaml
    for (var header in (ffigenMap[string.headers] as YamlList)) {
      var glob = Glob(header as String);
      for (var file in glob.listSync(followLinks: true)) {
        // TODO remove .c files later
        if (file.path.endsWith('.h') || file.path.endsWith('.c')) {
          headers.add(Header(file.path));
        }
      }
    }

    var headerFilter = ffigenMap[string.headerFilter] as YamlMap;
    if (headerFilter != null) {
      var include = headerFilter[string.include] as YamlList;
      // Add included header-filter from Yaml
      if (include != null) {
        for (var header in include) {
          includedInclusionHeaders.add(header as String);
        }
      }
      var exclude = headerFilter[string.exclude] as YamlList;
      // Add excluded header-filter from Yaml
      if (exclude != null) {
        for (var header in exclude) {
          excludedInclusionHeaders.add(header as String);
        }
      }
    }

    // Adding compilerOpts from yaml
    compilerOpts = (ffigenMap[string.compilerOpts] as String)?.split(' ');

    // Adding filters from yaml
    var filters = ffigenMap[string.filters] as YamlMap;
    if (filters != null) {
      // Add filter for functions from yaml
      var functions = filters[string.functions] as YamlMap;
      if (functions != null) {
        functionFilters = _extractFilter(functions);
      }

      // Add filter for structs from yaml
      var structs = filters[string.structs] as YamlMap;
      if (structs != null) {
        structFilters = _extractFilter(structs);
      }

      // Add filter for enums from yaml
      var enums = filters[string.enums] as YamlMap;
      if (enums != null) {
        enumClassFilters = _extractFilter(enums);
      }
    }
    _logger.finest('Config: ' + toString());
  }

  // Extracts a filter from a YamlMap
  Filter _extractFilter(YamlMap map) {
    List<String> includeMatchers, includeFull, excludeMatchers, excludeFull;

    var include = map[string.include] as YamlMap;
    if (include != null) {
      includeMatchers = (include[string.matches] as YamlList)
          ?.map((dynamic e) => e as String)
          ?.toList();
      includeFull = (include[string.names] as YamlList)
          ?.map((dynamic e) => e as String)
          ?.toList();
    }

    var exclude = map[string.exclude] as YamlMap;

    if (exclude != null) {
      excludeMatchers = (map[string.exclude][string.matches] as YamlList)
          ?.map((dynamic e) => e as String)
          ?.toList();
      excludeFull = (map[string.exclude][string.names] as YamlList)
          ?.map((dynamic e) => e as String)
          ?.toList();
    }

    return Filter(
      includeMatchers: includeMatchers,
      includeFull: includeFull,
      excludeMatchers: excludeMatchers,
      excludeFull: excludeFull,
    );
  }

  /// Use `Config.fromYaml` if extracting info from yaml file
  Config(
      {this.libclang_dylib_path, this.headers, this.excludedInclusionHeaders, this.includedInclusionHeaders});

  @override
  String toString() {
    return _raw != null ? _raw.toString() : 'Instance of `${runtimeType}`';
  }
}
