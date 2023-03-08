// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Validates the yaml input by the user, prints useful info for the user

import 'dart:io';

import 'package:config/config.dart' as pkg_config;
import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';
import 'package:package_config/package_config_types.dart';
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'config_types.dart';
import 'spec_utils.dart';

final _logger = Logger('ffigen.config_provider.config');

/// Provides configurations to other modules.
///
/// Handles validation, extraction of confiurations from yaml file.
class Config {
  /// Input filename.
  String? _filename;

  /// Package config.
  PackageConfig? _packageConfig;

  /// Location for llvm/lib folder.
  String get libclangDylib => _libclangDylib;
  late String _libclangDylib;

  /// Output file name.
  String get output => _output;
  late String _output;

  /// Symbol file config.
  SymbolFile? get symbolFile => _symbolFile;
  late SymbolFile? _symbolFile;

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

  /// Declaration config for Objective C interfaces.
  Declaration get objcInterfaces => _objcInterfaces;
  late Declaration _objcInterfaces;

  /// If enabled, the default behavior of all declaration filters is to exclude
  /// everything, rather than include everything.
  bool get excludeAllByDefault => _excludeAllByDefault;
  late bool _excludeAllByDefault;

  /// If generated bindings should be sorted alphabetically.
  bool get sort => _sort;
  late bool _sort;

  /// If typedef of supported types(int8_t) should be directly used.
  bool get useSupportedTypedefs => _useSupportedTypedefs;
  late bool _useSupportedTypedefs;

  /// Stores all the library imports specified by user including those for ffi
  /// and pkg_ffi.
  Map<String, LibraryImport> get libraryImports => _libraryImports;
  late Map<String, LibraryImport> _libraryImports;

  /// Stores all the symbol file maps name to ImportedType mappings specified by user.
  Map<String, ImportedType> get usrTypeMappings => _usrTypeMappings;
  late Map<String, ImportedType> _usrTypeMappings;

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

  /// Module prefixes for ObjC interfaces.
  ObjCModulePrefixer get objcModulePrefixer => _objcModulePrefixer;
  late ObjCModulePrefixer _objcModulePrefixer;

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

  FfiNativeConfig get ffiNativeConfig => _ffiNativeConfig;
  late FfiNativeConfig _ffiNativeConfig;

  Config._(this._filename, this._packageConfig);

  /// Create config from Yaml map.
  factory Config.fromYaml(YamlMap map,
      {String? filename, PackageConfig? packageConfig}) {
    final config = pkg_config.Config(
      fileParsed: map.cast(),
      fileSourceUri: Uri(path: filename),
    );

    return Config.fromConfig(
      config,
      filename: filename,
      packageConfig: packageConfig,
    );
  }

  /// Create config from Yaml map.
  factory Config.fromConfig(pkg_config.Config config,
      {String? filename, PackageConfig? packageConfig}) {
    final configspecs = Config._(filename, packageConfig);
    _logger.finest('Config: $config');

    final specs = configspecs._getSpecs();

    final result = configspecs._checkConfigs(config, specs);
    if (!result) {
      throw FormatException('Invalid configurations provided.');
    }

    configspecs._extract(config, specs);
    return configspecs;
  }

  /// Create config from a file.
  factory Config.fromFile(File file, {PackageConfig? packageConfig}) {
    // Throws a [YamlException] if it's unable to parse the Yaml.
    final configYaml = loadYaml(file.readAsStringSync()) as YamlMap;

    return Config.fromYaml(configYaml,
        filename: file.path, packageConfig: packageConfig);
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
  bool _checkConfigs(
      pkg_config.Config config, Map<List<String>, Specification> specs) {
    var result = true;
    for (final key in specs.keys) {
      final spec = specs[key];
      final value = config.getFileValue<Object>(key.join('.'));
      if (value != null) {
        result = result && spec!.validator(key, value);
      } else if (spec!.requirement == Requirement.yes) {
        _logger.severe("Key '$key' is required.");
        result = false;
      } else if (spec.requirement == Requirement.prefer) {
        _logger.warning("Prefer adding Key '$key' to your config.");
      }
    }
    // Warn about unknown keys.
    // warnUnknownKeys(specs.keys.toList(), map);
    // TODO(dacoharkes): Should the config allow access to the list of keys?
    // Should that access be uniform across env/cli/file? Environment is not
    // going to be empty.

    return result;
  }

  /// Extracts variables from Yaml according to given specs.
  ///
  /// Validation must be done beforehand, using [_checkConfigs].
  void _extract(
      pkg_config.Config config, Map<List<String>, Specification> specs) {
    for (final key in specs.keys) {
      final spec = specs[key]!;
      final value = spec.extractor(config) ?? spec.defaultValue?.call();
      spec.extractedResult(value);
    }
  }

  /// Returns map of various specifications available for our tool.
  ///
  /// Key: Name, Value: [Specification]
  Map<List<String>, Specification> _getSpecs() {
    return <List<String>, Specification>{
      [strings.llvmPath]: Specification<String>(
        key: [strings.llvmPath],
        requirement: Requirement.no,
        validator: llvmPathValidator,
        extractor: llvmPathExtractor,
        defaultValue: () => findDylibAtDefaultLocations(),
        extractedResult: (dynamic result) {
          _libclangDylib = result as String;
        },
      ),
      [strings.output]: Specification<OutputConfig>(
        key: [strings.output],
        requirement: Requirement.yes,
        validator: outputValidator,
        extractor: (dynamic value) =>
            outputExtractor(value, _filename, _packageConfig),
        extractedResult: (dynamic result) {
          _output = (result as OutputConfig).output;
          _symbolFile = result.symbolFile;
        },
      ),
      [strings.language]: Specification<Language>(
        key: [strings.language],
        requirement: Requirement.no,
        validator: languageValidator,
        extractor: languageExtractor,
        defaultValue: () => Language.c,
        extractedResult: (dynamic result) => _language = result as Language,
      ),
      [strings.headers]: Specification<Headers>(
        key: [strings.headers],
        requirement: Requirement.yes,
        validator: headersValidator,
        extractor: (dynamic value) => headersExtractor(value, _filename),
        extractedResult: (dynamic result) => _headers = result as Headers,
      ),
      [strings.compilerOpts]: Specification<List<String>>(
        key: [strings.compilerOpts],
        requirement: Requirement.no,
        validator: compilerOptsValidator,
        extractor: compilerOptsExtractor,
        defaultValue: () => [],
        extractedResult: (dynamic result) =>
            _compilerOpts = result as List<String>,
      ),
      [strings.compilerOptsAuto]: Specification<CompilerOptsAuto>(
        key: [strings.compilerOptsAuto],
          requirement: Requirement.no,
          validator: compilerOptsAutoValidator,
          extractor: compilerOptsAutoExtractor,
          defaultValue: () => CompilerOptsAuto(),
          extractedResult: (dynamic result) {
            _compilerOpts
                .addAll((result as CompilerOptsAuto).extractCompilerOpts());
        },
      ),
      [strings.functions]: Specification<Declaration>(
        key: [strings.functions],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _functionDecl = result as Declaration;
        },
      ),
      [strings.structs]: Specification<Declaration>(
        key: [strings.structs],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _structDecl = result as Declaration;
        },
      ),
      [strings.unions]: Specification<Declaration>(
        key: [strings.unions],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _unionDecl = result as Declaration;
        },
      ),
      [strings.enums]: Specification<Declaration>(
        key: [strings.enums],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _enumClassDecl = result as Declaration;
        },
      ),
      [strings.unnamedEnums]: Specification<Declaration>(
        key: [strings.unnamedEnums],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) =>
            _unnamedEnumConstants = result as Declaration,
      ),
      [strings.globals]: Specification<Declaration>(
        key: [strings.globals],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _globals = result as Declaration;
        },
      ),
      [strings.macros]: Specification<Declaration>(
        key: [strings.macros],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _macroDecl = result as Declaration;
        },
      ),
      [strings.typedefs]: Specification<Declaration>(
        key: [strings.typedefs],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _typedefs = result as Declaration;
        },
      ),
      [strings.objcInterfaces]: Specification<Declaration>(
        key: [strings.objcInterfaces],
        requirement: Requirement.no,
        validator: declarationConfigValidator,
        extractor: declarationConfigExtractor,
        defaultValue: () => Declaration(),
        extractedResult: (dynamic result) {
          _objcInterfaces = result as Declaration;
        },
      ),
      [strings.objcInterfaces, strings.objcModule]:
          Specification<Map<String, String>>(
        key: [strings.objcInterfaces, strings.objcModule],
        requirement: Requirement.no,
        validator: stringStringMapValidator,
        extractor: stringStringMapExtractor,
        defaultValue: () => <String, String>{},
        extractedResult: (dynamic result) => _objcModulePrefixer =
            ObjCModulePrefixer(result as Map<String, String>),
      ),
      [strings.libraryImports]: Specification<Map<String, LibraryImport>>(
        key: [strings.libraryImports],
        validator: libraryImportsValidator,
        extractor: libraryImportsExtractor,
        defaultValue: () => <String, LibraryImport>{},
        extractedResult: (dynamic result) {
          _libraryImports = result as Map<String, LibraryImport>;
        },
      ),
      [strings.import, strings.symbolFilesImport]:
          Specification<Map<String, ImportedType>>(
        key: [strings.import, strings.symbolFilesImport],
        validator: symbolFileImportValidator,
        extractor: (value) => symbolFileImportExtractor(
            value, _libraryImports, _filename, _packageConfig),
        defaultValue: () => <String, ImportedType>{},
        extractedResult: (dynamic result) {
          _usrTypeMappings = result as Map<String, ImportedType>;
        },
      ),
      [strings.typeMap, strings.typeMapTypedefs]:
          Specification<Map<String, List<String>>>(
        key: [strings.typeMap, strings.typeMapTypedefs],
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
        key: [strings.typeMap, strings.typeMapStructs],
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
        key: [strings.typeMap, strings.typeMapUnions],
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
        key: [strings.typeMap, strings.typeMapNativeTypes],
        validator: typeMapValidator,
        extractor: typeMapExtractor,
        defaultValue: () => <String, List<String>>{},
        extractedResult: (dynamic result) {
          _nativeTypeMappings = makeImportTypeMapping(
              result as Map<String, List<String>>, _libraryImports);
        },
      ),
      [strings.excludeAllByDefault]: Specification<bool>(
        key: [strings.excludeAllByDefault],
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        extractor2: booleanExtractor2,
        defaultValue: () => false,
        extractedResult: (dynamic result) =>
            _excludeAllByDefault = result as bool,
      ),
      [strings.sort]: Specification<bool>(
        key: [strings.sort],
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        extractor2: booleanExtractor2,
        defaultValue: () => false,
        extractedResult: (dynamic result) => _sort = result as bool,
      ),
      [strings.useSupportedTypedefs]: Specification<bool>(
        key: [strings.useSupportedTypedefs],
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        extractor2: booleanExtractor2,
        defaultValue: () => true,
        extractedResult: (dynamic result) =>
            _useSupportedTypedefs = result as bool,
      ),
      [strings.comments]: Specification<CommentType>(
        key: [strings.comments],
        requirement: Requirement.no,
        validator: commentValidator,
        extractor: commentExtractor,
        defaultValue: () => CommentType.def(),
        extractedResult: (dynamic result) =>
            _commentType = result as CommentType,
      ),
      [strings.structs, strings.dependencyOnly]:
          Specification<CompoundDependencies>(
        key: [strings.structs, strings.dependencyOnly],
        requirement: Requirement.no,
        validator: dependencyOnlyValidator,
        extractor: dependencyOnlyExtractor,
        defaultValue: () => CompoundDependencies.full,
        extractedResult: (dynamic result) =>
            _structDependencies = result as CompoundDependencies,
      ),
      [strings.unions, strings.dependencyOnly]:
          Specification<CompoundDependencies>(
        key: [strings.unions, strings.dependencyOnly],
        requirement: Requirement.no,
        validator: dependencyOnlyValidator,
        extractor: dependencyOnlyExtractor,
        defaultValue: () => CompoundDependencies.full,
        extractedResult: (dynamic result) =>
            _unionDependencies = result as CompoundDependencies,
      ),
      [strings.structs, strings.structPack]:
          Specification<StructPackingOverride>(
        key: [strings.structs, strings.structPack],
        requirement: Requirement.no,
        validator: structPackingOverrideValidator,
        extractor: structPackingOverrideExtractor,
        defaultValue: () => StructPackingOverride(),
        extractedResult: (dynamic result) =>
            _structPackingOverride = result as StructPackingOverride,
      ),
      [strings.name]: Specification<String>(
        key: [strings.name],
        requirement: Requirement.prefer,
        validator: dartClassNameValidator,
        extractor: stringExtractor,
        defaultValue: () => 'NativeLibrary',
        extractedResult: (dynamic result) => _wrapperName = result as String,
      ),
      [strings.description]: Specification<String?>(
        key: [strings.description],
        requirement: Requirement.prefer,
        validator: nonEmptyStringValidator,
        extractor: stringExtractor,
        defaultValue: () => null,
        extractedResult: (dynamic result) =>
            _wrapperDocComment = result as String?,
      ),
      [strings.preamble]: Specification<String?>(
        key: [strings.preamble],
        requirement: Requirement.no,
        validator: nonEmptyStringValidator,
        extractor: stringExtractor,
        extractedResult: (dynamic result) => _preamble = result as String?,
      ),
      [strings.useDartHandle]: Specification<bool>(
        key: [strings.useDartHandle],
        requirement: Requirement.no,
        validator: booleanValidator,
        extractor: booleanExtractor,
        extractor2: booleanExtractor2,
        defaultValue: () => true,
        extractedResult: (dynamic result) => _useDartHandle = result as bool,
      ),
      [strings.functions, strings.exposeFunctionTypedefs]:
          Specification<Includer>(
        key: [strings.functions, strings.exposeFunctionTypedefs],
        requirement: Requirement.no,
        validator: exposeFunctionTypeValidator,
        extractor: exposeFunctionTypeExtractor,
        defaultValue: () => Includer.excludeByDefault(),
        extractedResult: (dynamic result) =>
            _exposeFunctionTypedefs = result as Includer,
      ),
      [strings.functions, strings.leafFunctions]: Specification<Includer>(
        key: [strings.functions, strings.leafFunctions],
        requirement: Requirement.no,
        validator: leafFunctionValidator,
        extractor: leafFunctionExtractor,
        defaultValue: () => Includer.excludeByDefault(),
        extractedResult: (dynamic result) =>
            _leafFunctions = result as Includer,
      ),
      [strings.ffiNative]: Specification<FfiNativeConfig>(
        key: [strings.ffiNative],
        requirement: Requirement.no,
        validator: ffiNativeValidator,
        extractor: ffiNativeExtractor,
        defaultValue: () => FfiNativeConfig(enabled: false),
        extractedResult: (dynamic result) =>
            _ffiNativeConfig = result as FfiNativeConfig,
      )
    };
  }
}
