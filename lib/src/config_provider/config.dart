import 'dart:io';

import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

import 'package:ffigen/src/code_generator/type.dart';
import 'package:ffigen/src/header_parser/clang_bindings/clang_constants.dart';
import 'package:ffigen/src/header_parser/type_extractor/cxtypekindmap.dart';

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

  // If generated bindings should be alphabetically sorted
  bool sort;

  /// Use `Config.fromYaml` if extracting info from yaml file
  Config({
    @required this.libclang_dylib_path,
    @required this.headers,
    this.excludedInclusionHeaders = const {},
    this.includedInclusionHeaders = const {},
    this.compilerOpts,
    this.sort = false,
  })  : assert(libclang_dylib_path != null),
        assert(headers != null),
        assert(sort != null);

  /// [ffigenMap] has required configurations
  Config.fromYaml(YamlMap ffigenMap)
      : headers = [],
        includedInclusionHeaders = {},
        excludedInclusionHeaders = {} {
    _validateYamlFormat(ffigenMap);
    _raw = ffigenMap;

    _extractOutputFileName(ffigenMap);
    _extractLibclangDylibPath(ffigenMap);
    _extractHeaders(ffigenMap);
    _extractHeaderFilter(ffigenMap);
    _extractCompilerOpts(ffigenMap);
    _extractAllFilters(ffigenMap);
    _extractSizeMap(ffigenMap);
    _extractSort(ffigenMap);

    _logger.finest('Config: ' + toString());
  }

  void _validateYamlFormat(YamlMap ffigenMap) {
    var result = checkYaml(ffigenMap);
    if (result == CheckerResult.error) {
      _logger.severe('Please fix errors in Configurations and re-run the tool');
      exit(1);
    }
  }

  void _extractSort(YamlMap ffigenMap) {
    var sort = ffigenMap[string.sort] as bool;
    this.sort = sort ?? false;
  }

  void _extractSizeMap(YamlMap ffigenMap) {
    var sizemap = ffigenMap[string.sizemap] as YamlMap;
    if (sizemap != null) {
      if (sizemap.containsKey(string.SChar)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_SChar] =
            nativeSupportedType(sizemap[string.SChar]);
      }
      if (sizemap.containsKey(string.UChar)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_UChar] =
            nativeSupportedType(sizemap[string.UChar], signed: false);
      }
      if (sizemap.containsKey(string.Short)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_Short] =
            nativeSupportedType(sizemap[string.Short]);
      }
      if (sizemap.containsKey(string.UShort)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_UShort] =
            nativeSupportedType(sizemap[string.UShort], signed: false);
      }
      if (sizemap.containsKey(string.Int)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_Int] =
            nativeSupportedType(sizemap[string.Int]);
      }
      if (sizemap.containsKey(string.UInt)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_UInt] =
            nativeSupportedType(sizemap[string.UInt], signed: false);
      }
      if (sizemap.containsKey(string.Long)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_Long] =
            nativeSupportedType(sizemap[string.Long]);
      }
      if (sizemap.containsKey(string.ULong)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_ULong] =
            nativeSupportedType(sizemap[string.ULong], signed: false);
      }
      if (sizemap.containsKey(string.LongLong)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_LongLong] =
            nativeSupportedType(sizemap[string.LongLong]);
      }
      if (sizemap.containsKey(string.ULongLong)) {
        cxTypeKindToSupportedNativeTypes[CXTypeKind.CXType_ULongLong] =
            nativeSupportedType(sizemap[string.ULongLong], signed: false);
      }
    }
  }

  SupportedNativeType nativeSupportedType(dynamic scalar,
      {bool signed = true}) {
    int value = scalar as int;
    switch (value) {
      case 1:
        return signed ? SupportedNativeType.Int8 : SupportedNativeType.Uint8;
      case 2:
        return signed ? SupportedNativeType.Int16 : SupportedNativeType.Uint16;
      case 4:
        return signed ? SupportedNativeType.Int32 : SupportedNativeType.Uint32;
      case 8:
        return signed ? SupportedNativeType.Int64 : SupportedNativeType.Uint64;
      default:
        throw Exception('Unknown Config Value');
    }
  }

  void _extractAllFilters(YamlMap ffigenMap) {
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
  }

  List<String> _extractCompilerOpts(YamlMap ffigenMap) =>
      compilerOpts = (ffigenMap[string.compilerOpts] as String)?.split(' ');

  void _extractHeaderFilter(YamlMap ffigenMap) {
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
  }

  void _extractHeaders(YamlMap ffigenMap) {
    for (var header in (ffigenMap[string.headers] as YamlList)) {
      var glob = Glob(header as String);
      for (var file in glob.listSync(followLinks: true)) {
        // TODO remove .c files later
        if (file.path.endsWith('.h') || file.path.endsWith('.c')) {
          headers.add(Header(file.path));
        }
      }
    }
  }

  void _extractLibclangDylibPath(YamlMap ffigenMap) {
    libclang_dylib_path = ffigenMap[string.libclang_dylib] as String;
  }

  void _extractOutputFileName(YamlMap ffigenMap) {
    output = ffigenMap[string.output] as String;
  }

  /// Extracts a filter from filters in YamlMap
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

  @override
  String toString() {
    return _raw != null ? _raw.toString() : 'Instance of `${runtimeType}`';
  }
}
