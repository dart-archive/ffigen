import 'dart:io';

/// Validates the yaml input by the user,
/// prints useful info for the user

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/type_extractor/cxtypekindmap.dart';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'filter.dart';
import 'spec_utils.dart';

var _logger = Logger('config_provider/config');

/// Contains all config spec
class Config {
  /// output file name
  String output;

  /// libclang path (in accordance with the platform)
  ///
  /// contains .so / .dll / .dylib, as extracted by configspec
  ///
  /// cannot be null
  String libclang_dylib_path;

  /// path to headers
  ///
  /// This contains all the headers, after extraction from Globs
  ///
  /// Cannot be null
  List<String> headers;

  HeaderFilter headerFilter;

  /// commandLineArguments to pass to clang_compiler
  ///
  /// can be null
  List<String> compilerOpts;

  // Filter for functions
  Filter functionFilters;

  // Filter for structs
  Filter structFilters;

  // Filter for enumClass
  Filter enumClassFilters;

  // If generated bindings should be alphabetically sorted
  bool sort;

  // If typedef of supported types(int8_t) should be directly used
  bool useSupportedTypedefs;

  // contains map of all config
  // Map<String, Spec> _map;
  /// Use `Config.fromYaml` if extracting info from yaml file
  Config({
    @required this.libclang_dylib_path,
    @required this.headers,
    this.headerFilter,
    this.compilerOpts,
    this.sort = false,
    this.useSupportedTypedefs = true,
  })  : assert(libclang_dylib_path != null),
        assert(headers != null),
        assert(sort != null);

  Config._();

  /// Create config from Yaml map
  factory Config.fromYaml(YamlMap map) {
    var configspecs = Config._();
    _logger.finest('Config Map: ' + map.toString());

    var specs = configspecs._getSpecs();

    var result = configspecs._checkConfigs(map, specs);
    if (!result) {
      _logger.severe('Please fix errors in Configurations and re-run the tool');
      exit(1);
    }

    configspecs._extract(map, specs);
    return configspecs;
  }

  /// Validates Yaml according to given specs
  bool _checkConfigs(YamlMap map, Map<String, Spec> specs) {
    var _result = true;
    for (var key in specs.keys) {
      var spec = specs[key];
      if (spec.isRequired && !map.containsKey(key)) {
        _logger.severe('Key=${key} is required');
        _result = false;
      } else if (map.containsKey(key)) {
        _result = _result && spec.validator(key, map[key]);
      }
    }
    //warn about unknown keys
    for (var key in map.keys) {
      if (!specs.containsKey(key)) {
        _logger.warning('Unknown key found: $key');
      }
    }

    return _result;
  }

  /// Extracts variables from Yaml according to given specs
  ///
  /// Validation must be done
  void _extract(YamlMap map, Map<String, Spec> specs) {
    for (var key in specs.keys) {
      var spec = specs[key];
      if (map.containsKey(key)) {
        spec.extractedResult(spec.extractor(map[key]));
      } else {
        spec.extractedResult(spec.defaultValue);
      }
    }
  }

  /// The specs avaialble for our tool
  ///
  /// Key: Name, Value: Spec
  Map<String, Spec> _getSpecs() {
    return <String, Spec>{
      strings.output: Spec(
        description: 'Output file name',
        isRequired: true,
        validator: outputValidator,
        extractor: outputExtractor,
        defaultValue: null,
        extractedResult: (dynamic result) => output = result as String,
      ),
      strings.libclang_dylib_folder: Spec(
        description:
            'Path to libclang dynamic library, used to parse C headers',
        isRequired: true,
        validator: libclangDylibValidator,
        extractor: libclangDylibExtractor,
        extractedResult: (dynamic result) =>
            libclang_dylib_path = result as String,
      ),
      strings.headers: Spec(
        description: 'List of C headers to generate bindings of',
        isRequired: true,
        validator: headersValidator,
        extractor: headersExtractor,
        extractedResult: (dynamic result) => headers = result as List<String>,
      ),
      strings.headerFilter: Spec(
        description: 'Include/Exclude inclusion headers',
        validator: headerFilterValidator,
        extractor: headerFilterExtractor,
        defaultValue: HeaderFilter(),
        extractedResult: (dynamic result) {
          return headerFilter = result as HeaderFilter;
        },
      ),
      strings.compilerOpts: Spec(
        description: 'Raw compiler options to pass to clang compiler',
        isRequired: false,
        validator: compilerOptsValidator,
        extractor: compilerOptsExtractor,
        defaultValue: null,
        extractedResult: (dynamic result) =>
            compilerOpts = result as List<String>,
      ),
      strings.functions: Spec(
        description: 'Filter for functions',
        isRequired: false,
        validator: filterValidator,
        extractor: filterExtractor,
        defaultValue: null,
        extractedResult: (dynamic result) => functionFilters = result as Filter,
      ),
      strings.structs: Spec(
        description: 'Filter for Structs',
        isRequired: false,
        validator: filterValidator,
        extractor: filterExtractor,
        defaultValue: null,
        extractedResult: (dynamic result) => structFilters = result as Filter,
      ),
      strings.enums: Spec(
        description: 'Filter for enums',
        isRequired: false,
        validator: filterValidator,
        extractor: filterExtractor,
        defaultValue: null,
        extractedResult: (dynamic result) =>
            enumClassFilters = result as Filter,
      ),
      strings.sizemap: Spec(
        description: 'map of types: byte size in int',
        validator: sizemapValidator,
        extractor: sizemapExtractor,
        defaultValue: <int, SupportedNativeType>{},
        extractedResult: (dynamic result) {
          var map = result as Map<int, SupportedNativeType>;
          for (var key in map.keys) {
            if (cxTypeKindToSupportedNativeTypes.containsKey(key)) {
              cxTypeKindToSupportedNativeTypes[key] = map[key];
            }
          }
        },
      ),
      strings.sort: Spec(
        description: 'whether or not to sort the bindings alphabetically',
        isRequired: false,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: false,
        extractedResult: (dynamic result) => sort = result as bool,
      ),
      strings.useSupportedTypedefs: Spec(
        description: 'whether or not to directly map supported typedef by name',
        isRequired: false,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: true,
        extractedResult: (dynamic result) =>
            useSupportedTypedefs = result as bool,
      ),
    };
  }
}

/// Represents a spec in a config
class Spec {
  final String description;
  final bool Function(String name, dynamic value) validator;
  final dynamic Function(dynamic map) extractor;
  final dynamic defaultValue;
  final bool isRequired;
  final void Function(dynamic result) extractedResult;

  Spec({
    @required this.extractedResult,
    @required this.description,
    @required this.validator,
    @required this.extractor,
    this.defaultValue,
    this.isRequired = false,
  });
}

class HeaderFilter {
  Set<String> includedInclusionHeaders;
  Set<String> excludedInclusionHeaders;

  HeaderFilter({
    this.includedInclusionHeaders = const {},
    this.excludedInclusionHeaders = const {},
  });
}
