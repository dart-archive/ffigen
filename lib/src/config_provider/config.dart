// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Validates the yaml input by the user, prints useful info for the user

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/type_extractor/cxtypekindmap.dart';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'config_types.dart';
import 'spec_utils.dart';

final _logger = Logger('ffigen.config_provider.config');

/// Provides configurations to other modules.
///
/// Handles validation, extraction of confiurations from yaml file.
class Config {
  /// Location for llvm/lib folder.
  String get libclangDylib => _libclangDylib;
  late String _libclangDylib;

  /// output file name.
  String get output => _output;
  late String _output;
  // Holds headers and filters for header.
  Headers get headers => _headers;
  late Headers _headers;

  /// CommandLine Arguments to pass to clang_compiler.
  List<String> get compilerOpts => _compilerOpts;
  late List<String> _compilerOpts;

  /// Declaration config for Functions.
  Declaration get functionDecl => _functionDecl;
  late Declaration _functionDecl;

  /// Declaration config for Structs.
  Declaration get structDecl => _structDecl;
  late Declaration _structDecl;

  /// Declaration config for Enums.
  Declaration get enumClassDecl => _enumClassDecl;
  late Declaration _enumClassDecl;

  /// Declaration config for Unnamed enum constants.
  Declaration get unnamedEnumConstants => _unnamedEnumConstants;
  late Declaration _unnamedEnumConstants;

  /// Declaration config for Globals.
  Declaration get globals => _globals;
  late Declaration _globals;

  /// Declaration config for Macro constants.
  Declaration get macroDecl => _macroDecl;
  late Declaration _macroDecl;

  /// If generated bindings should be sorted alphabetically.
  bool get sort => _sort;
  late bool _sort;

  /// If typedef of supported types(int8_t) should be directly used.
  bool get useSupportedTypedefs => _useSupportedTypedefs;
  late bool _useSupportedTypedefs;

  /// Stores typedef name to NativeType mappings specified by user.
  Map<String, SupportedNativeType> get typedefNativeTypeMappings =>
      _typedefNativeTypeMappings;
  late Map<String, SupportedNativeType> _typedefNativeTypeMappings;

  /// Extracted Doc comment type.
  CommentType get commentType => _commentType;
  late CommentType _commentType;

  /// Whether structs that are dependencies should be included.
  StructDependencies get structDependencies => _structDependencies;
  late StructDependencies _structDependencies;

  /// If tool should generate array workarounds.
  ///
  /// If false(default), structs with inline array members will have all its
  /// members removed.
  bool get arrayWorkaround => _arrayWorkaround;
  late bool _arrayWorkaround;

  /// If dart bool should be generated for C booleans.
  bool get dartBool => _dartBool;
  late bool _dartBool;

  /// Name of the wrapper class.
  String get wrapperName => _wrapperName;
  late String _wrapperName;

  /// Doc comment for the wrapper class.
  String? get wrapperDocComment => _wrapperDocComment;
  String? _wrapperDocComment;

  /// Header of the generated bindings.
  String? get preamble => _preamble;
  String? _preamble;

  /// If `Dart_Handle` should be mapped with Handle/Object.
  bool get useDartHandle => _useDartHandle;
  late bool _useDartHandle;

  Config._();

  /// Create config from Yaml map.
  factory Config.fromYaml(YamlMap map) {
    final configspecs = Config._();
    _logger.finest('Config Map: ' + map.toString());

    final specs = configspecs._getSpecs();

    final result = configspecs._checkConfigs(map, specs);
    if (!result) {
      throw FormatException('Invalid configurations provided.');
    }

    configspecs._extract(map, specs);
    return configspecs;
  }

  /// Add compiler options for clang. If [highPriority] is true these are added
  /// to the front of the list.
  void addCompilerOpts(String compilerOpts, {bool highPriority = false}) {
    if (highPriority) {
      _compilerOpts.insertAll(
          0, compilerOptsToList(compilerOpts)); // Inserts at the front.
    } else {
      _compilerOpts.addAll(compilerOptsToList(compilerOpts));
    }
  }

  /// Checks if there are nested [key] in [map].
  bool _checkKeyInYaml(List<String> key, YamlMap map) {
    dynamic last = map;
    for (final k in key) {
      if (last is YamlMap) {
        if (!last.containsKey(k)) return false;
        last = last[k];
      } else {
        return false;
      }
    }
    return last != null;
  }

  /// Extracts value of nested [key] from [map].
  dynamic _getKeyValueFromYaml(List<String> key, YamlMap map) {
    if (_checkKeyInYaml(key, map)) {
      dynamic last = map;
      for (final k in key) {
        last = last[k];
      }
      return last;
    }

    return null;
  }

  /// Validates Yaml according to given specs.
  bool _checkConfigs(YamlMap map, Map<List<String>, Specification> specs) {
    var _result = true;
    for (final key in specs.keys) {
      final spec = specs[key];
      if (_checkKeyInYaml(key, map)) {
        _result =
            _result && spec!.validator(key, _getKeyValueFromYaml(key, map));
      } else if (spec!.requirement == Requirement.yes) {
        _logger.severe("Key '$key' is required.");
        _result = false;
      } else if (spec.requirement == Requirement.prefer) {
        _logger.warning("Prefer adding Key '$key' to your config.");
      }
    }
    // Warn about unknown keys.
    for (final key in map.keys) {
      final specString = specs.keys.map((e) => e.join(':')).toSet();
      if (!specString.contains(key)) {
        _logger.warning("Unknown key '$key' found.");
      }
    }

    return _result;
  }

  /// Extracts variables from Yaml according to given specs.
  ///
  /// Validation must be done beforehand, using [_checkConfigs].
  void _extract(YamlMap map, Map<List<String>, Specification> specs) {
    for (final key in specs.keys) {
      final spec = specs[key];
      if (_checkKeyInYaml(key, map)) {
        spec!.extractedResult(spec.extractor(_getKeyValueFromYaml(key, map)));
      } else {
        spec!.extractedResult(spec.defaultValue?.call());
      }
    }
  }

  /// Returns map of various specifications avaialble for our tool.
  ///
  /// Key: Name, Value: [Specification]
  Map<List<String>, Specification> _getSpecs() {
    return <List<String>, Specification>{
      [strings.llvmLib]: Specification<String>(
        requirement: Requirement.no,
        validator: llvmLibValidator,
        extractor: llvmLibExtractor,
        defaultValue: () => findDylibAtDefaultLocations(),
        extractedResult: (dynamic result) => _libclangDylib = result as String,
      ),
      [strings.output]: Specification<String>(
        requirement: Requirement.yes,
        validator: outputValidator,
        extractor: outputExtractor,
        extractedResult: (dynamic result) => _output = result as String,
      ),
      [strings.headers]: Specification<Headers>(
        requirement: Requirement.yes,
        validator: headersValidator,
        extractor: headersExtractor,
        extractedResult: (dynamic result) => _headers = result as Headers,
      ),
      [strings.compilerOpts]: Specification<List<String>>(
        requirement: Requirement.no,
        validator: compilerOptsValidator,
        extractor: compilerOptsExtractor,
        defaultValue: () => [],
        extractedResult: (dynamic result) =>
            _compilerOpts = result as List<String>,
      ),
      [strings.functions]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _functionDecl = result as Declaration;
        },
      ),
      [strings.structs]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _structDecl = result as Declaration;
        },
      ),
      [strings.enums]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _enumClassDecl = result as Declaration;
        },
      ),
      [strings.unnamedEnums]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) =>
            _unnamedEnumConstants = result as Declaration,
      ),
      [strings.globals]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _globals = result as Declaration;
        },
      ),
      [strings.macros]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _macroDecl = result as Declaration;
        },
      ),
      [strings.sizemap]: Specification<Map<int, SupportedNativeType>>(
        validator: sizemapValidator,
        extractor: sizemapExtractor,
        defaultValue: () => <int, SupportedNativeType>{},
        extractedResult: (dynamic result) {
          final map = result as Map<int, SupportedNativeType>;
          for (final key in map.keys) {
            if (cxTypeKindToSupportedNativeTypes.containsKey(key)) {
              cxTypeKindToSupportedNativeTypes[key] = map[key]!;
            }
          }
        },
      ),
      [strings.typedefmap]: Specification<Map<String, SupportedNativeType>>(
        validator: typedefmapValidator,
        extractor: typedefmapExtractor,
        defaultValue: () => <String, SupportedNativeType>{},
        extractedResult: (dynamic result) => _typedefNativeTypeMappings =
            result as Map<String, SupportedNativeType>,
      ),
      [strings.sort]: Specification<bool>(
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => false,
        extractedResult: (dynamic result) => _sort = result as bool,
      ),
      [strings.useSupportedTypedefs]: Specification<bool>(
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => true,
        extractedResult: (dynamic result) =>
            _useSupportedTypedefs = result as bool,
      ),
      [strings.comments]: Specification<CommentType>(
        requirement: Requirement.no,
        validator: commentValidator,
        extractor: commentExtractor,
        defaultValue: () => CommentType.def(),
        extractedResult: (dynamic result) =>
            _commentType = result as CommentType,
      ),
      [strings.structs, strings.structDependencies]:
          Specification<StructDependencies>(
        requirement: Requirement.no,
        validator: structDependenciesValidator,
        extractor: structDependenciesExtractor,
        defaultValue: () => StructDependencies.full,
        extractedResult: (dynamic result) =>
            _structDependencies = result as StructDependencies,
      ),
      [strings.arrayWorkaround]: Specification<bool>(
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => false,
        extractedResult: (dynamic result) => _arrayWorkaround = result as bool,
      ),
      [strings.dartBool]: Specification<bool>(
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => true,
        extractedResult: (dynamic result) => _dartBool = result as bool,
      ),
      [strings.name]: Specification<String>(
        requirement: Requirement.prefer,
        validator: dartClassNameValidator,
        extractor: stringExtractor,
        defaultValue: () => 'NativeLibrary',
        extractedResult: (dynamic result) => _wrapperName = result as String,
      ),
      [strings.description]: Specification<String?>(
        requirement: Requirement.prefer,
        validator: nonEmptyStringValidator,
        extractor: stringExtractor,
        defaultValue: () => null,
        extractedResult: (dynamic result) =>
            _wrapperDocComment = result as String?,
      ),
      [strings.preamble]: Specification<String?>(
        requirement: Requirement.no,
        validator: nonEmptyStringValidator,
        extractor: stringExtractor,
        extractedResult: (dynamic result) => _preamble = result as String?,
      ),
      [strings.useDartHandle]: Specification<bool>(
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        defaultValue: () => true,
        extractedResult: (dynamic result) => _useDartHandle = result as bool,
      ),
    };
  }
}
