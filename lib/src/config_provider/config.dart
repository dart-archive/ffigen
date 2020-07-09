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
import 'declaration.dart';
import 'spec_utils.dart';

var _logger = Logger('config_provider:config.dart');

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

  /// Declaration config for Functions.
  Declaration functionDecl;

  /// Declaration config for Structs.
  Declaration structDecl;

  /// Declaration config for Enums.
  Declaration enumClassDecl;

  /// If generated bindings should be sorted alphabetically.
  bool sort;

  /// If typedef of supported types(int8_t) should be directly used.
  bool useSupportedTypedefs;

  /// Extracted Doc comment type.
  String comment;

  /// If tool should generate array workarounds.
  ///
  /// If false(default), structs with inline array members will have all its
  /// members removed.
  bool arrayWorkaround;

  /// Name of the wrapper class.
  String wrapperName;

  /// Doc comment for the wrapper class.
  String wrapperDocComment;

  /// Header of the generated bindings.
  String preamble;

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
      if (map.containsKey(key)) {
        _result = _result && spec.validator(key, map[key]);
      } else if (spec.requirement == Requirement.yes) {
        _logger.severe("Key '${key}' is required.");
        _result = false;
      } else if (spec.requirement == Requirement.prefer) {
        _logger.warning("Prefer adding Key '$key' to your config.");
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
        requirement: Requirement.yes,
        validator: outputValidator,
        extractor: outputExtractor,
        extractedResult: (dynamic result) => output = result as String,
      ),
      strings.libclang_dylib_folder: Specification<String>(
        description:
            'Path to folder containing libclang dynamic library, used to parse C headers',
        requirement: Requirement.no,
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
        requirement: Requirement.yes,
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
        requirement: Requirement.no,
        validator: compilerOptsValidator,
        extractor: compilerOptsExtractor,
        extractedResult: (dynamic result) =>
            compilerOpts = result as List<String>,
      ),
      strings.functions: Specification<Declaration>(
        description: 'Filter for functions',
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(declarationTypeName: 'Function'),
        extractedResult: (dynamic result) {
          functionDecl = result as Declaration;
          functionDecl.declarationTypeName = 'Function';
        },
      ),
      strings.structs: Specification<Declaration>(
        description: 'Filter for Structs',
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(declarationTypeName: 'Struct'),
        extractedResult: (dynamic result) {
          structDecl = result as Declaration;
          structDecl.declarationTypeName = 'Struct';
        },
      ),
      strings.enums: Specification<Declaration>(
        description: 'Filter for enums',
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(declarationTypeName: 'Enum'),
        extractedResult: (dynamic result) {
          enumClassDecl = result as Declaration;
          enumClassDecl.declarationTypeName = 'Enum';
        },
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
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => false,
        extractedResult: (dynamic result) => sort = result as bool,
      ),
      strings.useSupportedTypedefs: Specification<bool>(
        description: 'whether or not to directly map supported typedef by name',
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => true,
        extractedResult: (dynamic result) =>
            useSupportedTypedefs = result as bool,
      ),
      strings.comments: Specification<String>(
        description: 'Type of comment to extract',
        requirement: Requirement.no,
        validator: commentValidator,
        extractor: commentExtractor,
        defaultValue: () => strings.brief,
        extractedResult: (dynamic result) => comment = result as String,
      ),
      strings.arrayWorkaround: Specification<bool>(
        description:
            'whether or not to generate workarounds for inline arrays in structures',
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => false,
        extractedResult: (dynamic result) => arrayWorkaround = result as bool,
      ),
      strings.name: Specification<String>(
        description: 'Name of the wrapper class',
        requirement: Requirement.prefer,
        validator: dartClassNameValidator,
        extractor: stringExtractor,
        defaultValue: () => 'NativeLibrary',
        extractedResult: (dynamic result) => wrapperName = result as String,
      ),
      strings.description: Specification<String>(
        description: 'Doc comment for the wrapper class',
        requirement: Requirement.prefer,
        validator: nonEmptyStringValidator,
        extractor: stringExtractor,
        defaultValue: () => null,
        extractedResult: (dynamic result) =>
            wrapperDocComment = result as String,
      ),
      strings.preamble: Specification<String>(
        description: 'Raw header string for the generated file',
        requirement: Requirement.no,
        validator: nonEmptyStringValidator,
        extractor: stringExtractor,
        extractedResult: (dynamic result) => preamble = result as String,
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

  final Requirement requirement;
  final void Function(dynamic result) extractedResult;

  Specification({
    @required this.extractedResult,
    @required this.description,
    @required this.validator,
    @required this.extractor,
    this.defaultValue,
    this.requirement = Requirement.no,
  });
}

enum Requirement { yes, prefer, no }

class HeaderFilter {
  Set<String> includedInclusionHeaders;
  Set<String> excludedInclusionHeaders;

  HeaderFilter({
    this.includedInclusionHeaders = const {},
    this.excludedInclusionHeaders = const {},
  });
}
