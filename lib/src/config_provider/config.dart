// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Validates the yaml input by the user, prints useful info for the user

import 'package:ffigen/src/code_generator.dart';

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

  /// Output file name.
  String get output => _output;
  late String _output;

  /// Language that ffigen is consuming.
  Language get language => _language;
  late Language _language;

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

  /// Declaration config for Unions.
  Declaration get unionDecl => _unionDecl;
  late Declaration _unionDecl;

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

  /// Declaration config for Typedefs.
  Declaration get typedefs => _typedefs;
  late Declaration _typedefs;

  /// If generated bindings should be sorted alphabetically.
  bool get sort => _sort;
  late bool _sort;

  /// If typedef of supported types(int8_t) should be directly used.
  bool get useSupportedTypedefs => _useSupportedTypedefs;
  late bool _useSupportedTypedefs;

  /// Stores all the library imports specified by user including those for ffi and pkg_ffi.
  Map<String, LibraryImport> get libraryImports => _libraryImports;
  late Map<String, LibraryImport> _libraryImports;

  /// Stores typedef name to ImportedType mappings specified by user.
  Map<String, ImportedType> get typedefTypeMappings => _typedefTypeMappings;
  late Map<String, ImportedType> _typedefTypeMappings;

  /// Stores struct name to ImportedType mappings specified by user.
  Map<String, ImportedType> get structTypeMappings => _structTypeMappings;
  late Map<String, ImportedType> _structTypeMappings;

  /// Stores union name to ImportedType mappings specified by user.
  Map<String, ImportedType> get unionTypeMappings => _unionTypeMappings;
  late Map<String, ImportedType> _unionTypeMappings;

  /// Stores native int name to ImportedType mappings specified by user.
  Map<String, ImportedType> get nativeTypeMappings => _nativeTypeMappings;
  late Map<String, ImportedType> _nativeTypeMappings;

  /// Extracted Doc comment type.
  CommentType get commentType => _commentType;
  late CommentType _commentType;

  /// Whether structs that are dependencies should be included.
  CompoundDependencies get structDependencies => _structDependencies;
  late CompoundDependencies _structDependencies;

  /// Whether unions that are dependencies should be included.
  CompoundDependencies get unionDependencies => _unionDependencies;
  late CompoundDependencies _unionDependencies;

  /// Holds config for how struct packing should be overriden.
  StructPackingOverride get structPackingOverride => _structPackingOverride;
  late StructPackingOverride _structPackingOverride;

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

  Includer get exposeFunctionTypedefs => _exposeFunctionTypedefs;
  late Includer _exposeFunctionTypedefs;

  Includer get leafFunctions => _leafFunctions;
  late Includer _leafFunctions;

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

  /// Validates Yaml according to given specs.
  bool _checkConfigs(YamlMap map, Map<List<String>, Specification> specs) {
    var _result = true;
    for (final key in specs.keys) {
      final spec = specs[key];
      if (checkKeyInYaml(key, map)) {
        _result =
            _result && spec!.validator(key, getKeyValueFromYaml(key, map));
      } else if (spec!.requirement == Requirement.yes) {
        _logger.severe("Key '$key' is required.");
        _result = false;
      } else if (spec.requirement == Requirement.prefer) {
        _logger.warning("Prefer adding Key '$key' to your config.");
      }
    }
    // Warn about unknown keys.
    warnUnknownKeys(specs.keys.toList(), map);

    return _result;
  }

  /// Extracts variables from Yaml according to given specs.
  ///
  /// Validation must be done beforehand, using [_checkConfigs].
  void _extract(YamlMap map, Map<List<String>, Specification> specs) {
    for (final key in specs.keys) {
      final spec = specs[key];
      if (checkKeyInYaml(key, map)) {
        spec!.extractedResult(spec.extractor(getKeyValueFromYaml(key, map)));
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
      [strings.llvmPath]: Specification<String>(
        requirement: Requirement.no,
        validator: llvmPathValidator,
        extractor: llvmPathExtractor,
        defaultValue: () => findDylibAtDefaultLocations(),
        extractedResult: (dynamic result) {
          _libclangDylib = result as String;
        },
      ),
      [strings.output]: Specification<String>(
        requirement: Requirement.yes,
        validator: outputValidator,
        extractor: outputExtractor,
        extractedResult: (dynamic result) => _output = result as String,
      ),
      [strings.language]: Specification<Language>(
        requirement: Requirement.no,
        validator: languageValidator,
        extractor: languageExtractor,
        defaultValue: () => Language.c,
        extractedResult: (dynamic result) => _language = result as Language,
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
      [strings.compilerOptsAuto]: Specification<CompilerOptsAuto>(
          requirement: Requirement.no,
          validator: compilerOptsAutoValidator,
          extractor: compilerOptsAutoExtractor,
          defaultValue: () => CompilerOptsAuto(),
          extractedResult: (dynamic result) {
            _compilerOpts
                .addAll((result as CompilerOptsAuto).extractCompilerOpts());
          }),
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
      [strings.unions]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _unionDecl = result as Declaration;
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
      [strings.typedefs]: Specification<Declaration>(
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _typedefs = result as Declaration;
        },
      ),
      [strings.libraryImports]: Specification<Map<String, LibraryImport>>(
        validator: libraryImportsValidator,
        extractor: libraryImportsExtractor,
        defaultValue: () => <String, LibraryImport>{},
        extractedResult: (dynamic result) {
          _libraryImports = result as Map<String, LibraryImport>;
        },
      ),
      [strings.typeMap, strings.typeMapTypedefs]:
          Specification<Map<String, List<String>>>(
        validator: typeMapValidator,
        extractor: typeMapExtractor,
        defaultValue: () => <String, List<String>>{},
        extractedResult: (dynamic result) {
          _typedefTypeMappings = makeImportTypeMapping(
              result as Map<String, List<String>>, _libraryImports);
        },
      ),
      [strings.typeMap, strings.typeMapStructs]:
          Specification<Map<String, List<String>>>(
        validator: typeMapValidator,
        extractor: typeMapExtractor,
        defaultValue: () => <String, List<String>>{},
        extractedResult: (dynamic result) {
          _structTypeMappings = makeImportTypeMapping(
              result as Map<String, List<String>>, _libraryImports);
        },
      ),
      [strings.typeMap, strings.typeMapUnions]:
          Specification<Map<String, List<String>>>(
        validator: typeMapValidator,
        extractor: typeMapExtractor,
        defaultValue: () => <String, List<String>>{},
        extractedResult: (dynamic result) {
          _unionTypeMappings = makeImportTypeMapping(
              result as Map<String, List<String>>, _libraryImports);
        },
      ),
      [strings.typeMap, strings.typeMapNativeTypes]:
          Specification<Map<String, List<String>>>(
        validator: typeMapValidator,
        extractor: typeMapExtractor,
        defaultValue: () => <String, List<String>>{},
        extractedResult: (dynamic result) {
          _nativeTypeMappings = makeImportTypeMapping(
              result as Map<String, List<String>>, _libraryImports);
        },
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
      [strings.structs, strings.dependencyOnly]:
          Specification<CompoundDependencies>(
        requirement: Requirement.no,
        validator: dependencyOnlyValidator,
        extractor: dependencyOnlyExtractor,
        defaultValue: () => CompoundDependencies.full,
        extractedResult: (dynamic result) =>
            _structDependencies = result as CompoundDependencies,
      ),
      [strings.unions, strings.dependencyOnly]:
          Specification<CompoundDependencies>(
        requirement: Requirement.no,
        validator: dependencyOnlyValidator,
        extractor: dependencyOnlyExtractor,
        defaultValue: () => CompoundDependencies.full,
        extractedResult: (dynamic result) =>
            _unionDependencies = result as CompoundDependencies,
      ),
      [strings.structs, strings.structPack]:
          Specification<StructPackingOverride>(
        requirement: Requirement.no,
        validator: structPackingOverrideValidator,
        extractor: structPackingOverrideExtractor,
        defaultValue: () => StructPackingOverride(),
        extractedResult: (dynamic result) =>
            _structPackingOverride = result as StructPackingOverride,
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
      [strings.functions, strings.exposeFunctionTypedefs]:
          Specification<Includer>(
        requirement: Requirement.no,
        validator: exposeFunctionTypeValidator,
        extractor: exposeFunctionTypeExtractor,
        defaultValue: () => Includer.excludeByDefault(),
        extractedResult: (dynamic result) =>
            _exposeFunctionTypedefs = result as Includer,
      ),
      [strings.functions, strings.leafFunctions]: Specification<Includer>(
        requirement: Requirement.no,
        validator: leafFunctionValidator,
        extractor: leafFunctionExtractor,
        defaultValue: () => Includer.excludeByDefault(),
        extractedResult: (dynamic result) =>
            _leafFunctions = result as Includer,
      ),
    };
  }
}
