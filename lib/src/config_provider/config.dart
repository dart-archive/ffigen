// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Validates the yaml input by the user, prints useful info for the user

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/type_extractor/cxtypekindmap.dart';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'filter.dart';
import 'spec_utils.dart';

var _logger = Logger('config_provider/config');

/// Provides configurations to other modules.
///
/// Handles validation, extraction of confiurations from yaml file.
class Config {
  /// output file name.
  String output;

  /// libclang path (in accordance with the platform).
  ///
  /// File may have the following extensions - `.so` / `.dll` / `.dylib`
  /// as extracted by configspec.
  String libclang_dylib_path;

  /// Path to headers.
  ///
  /// This contains all the headers, after extraction from Globs.
  List<String> headers;

  /// Filter for headers.
  HeaderFilter headerFilter;

  /// CommandLine Arguments to pass to clang_compiler.
  List<String> compilerOpts;

  /// Filter for functions.
  Filter functionFilters;

  /// Filter for structs.
  Filter structFilters;

  /// Filter for enumClass.
  Filter enumClassFilters;

  /// If generated bindings should be sorted alphabetically.
  bool sort;

  /// If typedef of supported types(int8_t) should be directly used.
  bool useSupportedTypedefs;

  /// If tool should extract doc comment from bindings.
  bool extractComments;

  /// Name of the init function used to initialise the dynamic library.
  String initFunctionName;

  /// Name of the dylib variable name used in bindings.
  String dylibVariableName;

  /// Header of the generated bindings.
  String preamble;

  /// The import prefix used when importing dart:ffi in bindings.
  String ffiLibraryPrefix;

  /// Prefix for functions.
  String functionPrefix;

  /// Suffix for functions.
  String functionSuffix;

  /// Prefix for structs.
  String structPrefix;

  /// Suffix for structs.
  String structSuffix;

  /// Prefix for enums.
  String enumPrefix;

  /// Sufix for enums.
  String enumSuffix;

  Config._();

  /// Create config from Yaml map.
  ///
  /// Ensure that log printing is setup before using this.
  factory Config.fromYaml(YamlMap map) {
    final configspecs = Config._();
    _logger.finest('Config Map: ' + map.toString());

    final specs = configspecs._getSpecs();

    final result = configspecs._checkConfigs(map, specs);
    if (!result) {
      _logger.info('Please fix errors in Configurations and re-run the tool');
      exit(1);
    }

    configspecs._extract(map, specs);
    return configspecs;
  }

  /// Validates Yaml according to given specs.
  bool _checkConfigs(YamlMap map, Map<String, Specification> specs) {
    var _result = true;
    for (final key in specs.keys) {
      final spec = specs[key];
      if (spec.isRequired && !map.containsKey(key)) {
        _logger.severe("Key '${key}' is required.");
        _result = false;
      } else if (map.containsKey(key)) {
        _result = _result && spec.validator(key, map[key]);
      }
    }
    // Warn about unknown keys.
    for (final key in map.keys) {
      if (!specs.containsKey(key)) {
        _logger.warning("Unknown key '$key' found.");
      }
    }

    return _result;
  }

  /// Extracts variables from Yaml according to given specs.
  ///
  /// Validation must be done beforehand, using [_checkConfigs].
  void _extract(YamlMap map, Map<String, Specification> specs) {
    for (final key in specs.keys) {
      final spec = specs[key];
      if (map.containsKey(key)) {
        spec.extractedResult(spec.extractor(map[key]));
      } else {
        spec.extractedResult(spec.defaultValue?.call());
      }
    }
  }

  /// Returns map of various specifications avaialble for our tool.
  ///
  /// Key: Name, Value: [Specification]
  Map<String, Specification> _getSpecs() {
    return <String, Specification>{
      strings.output: Specification<String>(
        description: 'Output file name',
        isRequired: true,
        validator: outputValidator,
        extractor: outputExtractor,
        extractedResult: (dynamic result) => output = result as String,
      ),
      strings.libclang_dylib_folder: Specification<String>(
        description:
            'Path to folder containing libclang dynamic library, used to parse C headers',
        isRequired: false,
        defaultValue: () => getDylibPath(Platform.script
            .resolve(path.join('..', 'tool', 'wrapped_libclang'))
            .toFilePath()),
        validator: libclangDylibValidator,
        extractor: libclangDylibExtractor,
        extractedResult: (dynamic result) =>
            libclang_dylib_path = result as String,
      ),
      strings.headers: Specification<List<String>>(
        description: 'List of C headers to generate bindings of',
        isRequired: true,
        validator: headersValidator,
        extractor: headersExtractor,
        extractedResult: (dynamic result) => headers = result as List<String>,
      ),
      strings.headerFilter: Specification<HeaderFilter>(
        description: 'Include/Exclude inclusion headers',
        validator: headerFilterValidator,
        extractor: headerFilterExtractor,
        defaultValue: () => HeaderFilter(),
        extractedResult: (dynamic result) {
          return headerFilter = result as HeaderFilter;
        },
      ),
      strings.compilerOpts: Specification<List<String>>(
        description: 'Raw compiler options to pass to clang compiler',
        isRequired: false,
        validator: compilerOptsValidator,
        extractor: compilerOptsExtractor,
        extractedResult: (dynamic result) =>
            compilerOpts = result as List<String>,
      ),
      strings.functions: Specification<Filter>(
        description: 'Filter for functions',
        isRequired: false,
        validator: filterValidator,
        extractor: filterExtractor,
        extractedResult: (dynamic result) => functionFilters = result as Filter,
      ),
      strings.structs: Specification<Filter>(
        description: 'Filter for Structs',
        isRequired: false,
        validator: filterValidator,
        extractor: filterExtractor,
        extractedResult: (dynamic result) => structFilters = result as Filter,
      ),
      strings.enums: Specification<Filter>(
        description: 'Filter for enums',
        isRequired: false,
        validator: filterValidator,
        extractor: filterExtractor,
        extractedResult: (dynamic result) =>
            enumClassFilters = result as Filter,
      ),
      strings.sizemap: Specification<Map<int, SupportedNativeType>>(
        description: 'map of types: byte size in int',
        validator: sizemapValidator,
        extractor: sizemapExtractor,
        defaultValue: () => <int, SupportedNativeType>{},
        extractedResult: (dynamic result) {
          final map = result as Map<int, SupportedNativeType>;
          for (final key in map.keys) {
            if (cxTypeKindToSupportedNativeTypes.containsKey(key)) {
              cxTypeKindToSupportedNativeTypes[key] = map[key];
            }
          }
        },
      ),
      strings.sort: Specification<bool>(
        description: 'whether or not to sort the bindings alphabetically',
        isRequired: false,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => false,
        extractedResult: (dynamic result) => sort = result as bool,
      ),
      strings.useSupportedTypedefs: Specification<bool>(
        description: 'whether or not to directly map supported typedef by name',
        isRequired: false,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => true,
        extractedResult: (dynamic result) =>
            useSupportedTypedefs = result as bool,
      ),
      strings.extractComments: Specification<bool>(
        description: 'whether or not to extract comments from bindings',
        isRequired: false,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => true,
        extractedResult: (dynamic result) => extractComments = result as bool,
      ),
      strings.initFunctionName: Specification<String>(
        description: 'Name of the init function to use',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => 'init',
        extractedResult: (dynamic result) =>
            initFunctionName = result as String,
      ),
      strings.dylibVariableName: Specification<String>(
        description: 'Name of the dylib variable used in bindings',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '_dylib',
        extractedResult: (dynamic result) =>
            dylibVariableName = result as String,
      ),
      strings.ffiLibraryPrefix: Specification<String>(
        description: 'Import prefix for dart:ffi used in bindings',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => 'ffi',
        extractedResult: (dynamic result) =>
            ffiLibraryPrefix = result as String,
      ),
      strings.preamble: Specification<String>(
        description: 'Header String for the generated bindings',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '/// AUTO GENERATED FILE, DO NOT EDIT.',
        extractedResult: (dynamic result) => preamble = result as String,
      ),
      strings.functionPrefix: Specification<String>(
        description: 'Prefix for generated Functions',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '',
        extractedResult: (dynamic result) => functionPrefix = result as String,
      ),
      strings.functionSuffix: Specification<String>(
        description: 'Suffix for generated Functions',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '',
        extractedResult: (dynamic result) => functionSuffix = result as String,
      ),
      strings.structPrefix: Specification<String>(
        description: 'Prefix for generated Structs',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '',
        extractedResult: (dynamic result) => structPrefix = result as String,
      ),
      strings.structSuffix: Specification<String>(
        description: 'Sufix for generated Structs',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '',
        extractedResult: (dynamic result) => structSuffix = result as String,
      ),
      strings.enumPrefix: Specification<String>(
        description: 'Prefix for generated Enums',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '',
        extractedResult: (dynamic result) => enumPrefix = result as String,
      ),
      strings.enumSuffix: Specification<String>(
        description: 'Sufix for generated Enums',
        isRequired: false,
        validator: stringValidator,
        extractor: stringExtractor,
        defaultValue: () => '',
        extractedResult: (dynamic result) => enumSuffix = result as String,
      ),
    };
  }
}

/// Represents a single specification in configurations.
///
/// [E] is the return type of the extractedResult.
class Specification<E> {
  final String description;
  final bool Function(String name, dynamic value) validator;
  final E Function(dynamic map) extractor;
  final E Function() defaultValue;

  final bool isRequired;
  final void Function(dynamic result) extractedResult;

  Specification({
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
