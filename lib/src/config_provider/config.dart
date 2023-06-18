// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Validates the yaml input by the user, prints useful info for the user

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';
import 'package:package_config/package_config_types.dart';
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'config_types.dart';
import 'schema.dart';
import 'spec_utils.dart';

final _logger = Logger('ffigen.config_provider.config');

/// Provides configurations to other modules.
///
/// Handles validation, extraction of configurations from a yaml file.
class Config {
  /// Input filename.
  String? get filename => _filename;
  String? _filename;

  /// Package config.
  PackageConfig? get packageConfig => _packageConfig;
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

  /// VarArg function handling.
  Map<String, List<VarArgFunction>> get varArgFunctions => _varArgFunctions;
  late Map<String, List<VarArgFunction>> _varArgFunctions = {};

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
    final configspecs = Config._(filename, packageConfig);
    _logger.finest('Config Map: $map');

    final ffigenSchema = configspecs._getRootSchema();
    final result = ffigenSchema.validate(map);
    if (!result) {
      throw FormatException('Invalid configurations provided.');
    }

    ffigenSchema.extract(map);
    return configspecs;
  }

  /// Create config from a file.
  factory Config.fromFile(File file, {PackageConfig? packageConfig}) {
    // Throws a [YamlException] if it's unable to parse the Yaml.
    final configYaml = loadYaml(file.readAsStringSync()) as YamlMap;

    return Config.fromYaml(configYaml,
        filename: file.path, packageConfig: packageConfig);
  }

  /// Returns the root Schema object.
  static Schema getsRootSchema() {
    final configspecs = Config._(null, null);
    return configspecs._getRootSchema();
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

  Schema _getRootSchema() {
    return FixedMapSchema<dynamic>(
      requiredKeys: [strings.output, strings.headers],
      keys: {
        strings.llvmPath: ListSchema<String>(
          childSchema: StringSchema(),
          transform: (node) => llvmPathExtractor(node.value),
          defaultValue: (node) => findDylibAtDefaultLocations(),
          result: (node) => _libclangDylib = node.value as String,
        ),
        strings.output: OneOfSchema<dynamic>(
          childSchemas: [
            StringSchema(),
            FixedMapSchema<dynamic>(
              requiredKeys: [strings.bindings],
              keys: {
                strings.bindings: StringSchema(),
                strings.symbolFile: FixedMapSchema<String>(
                  requiredKeys: [strings.output, strings.importPath],
                  keys: {
                    strings.output: StringSchema(),
                    strings.importPath: StringSchema()
                  },
                )
              },
            )
          ],
          transform: (node) =>
              outputExtractor(node.value, filename, packageConfig),
          result: (node) {
            _output = (node.value as OutputConfig).output;
            _symbolFile = (node.value as OutputConfig).symbolFile;
          },
        ),
        strings.language: EnumSchema<String>(
          allowedValues: {strings.langC, strings.langObjC},
          transform: (node) {
            if ((node.value == strings.langObjC)) {
              _logger.severe(
                  'Objective C support is EXPERIMENTAL. The API may change '
                  'in a breaking way without notice.');
              return Language.objc;
            } else {
              return Language.c;
            }
          },
          defaultValue: (node) => Language.c,
          result: (node) => _language = node.value as Language,
        ),
        strings.headers: FixedMapSchema<List<String>>(
          requiredKeys: [strings.entryPoints],
          keys: {
            strings.entryPoints:
                ListSchema<String>(childSchema: StringSchema()),
            strings.includeDirectives:
                ListSchema<String>(childSchema: StringSchema()),
          },
          transform: (node) => headersExtractor(node.value, filename),
          result: (node) => _headers = node.value as Headers,
        ),
        strings.compilerOpts: OneOfSchema(
          childSchemas: [
            StringSchema(),
            ListSchema<String>(childSchema: StringSchema())
          ],
          transform: (node) => compilerOptsExtractor(node.value),
          defaultValue: (node) => <String>[],
          result: (node) => _compilerOpts = node.value as List<String>,
        ),
        strings.compilerOptsAuto: FixedMapSchema<dynamic>(
          keys: {
            strings.macos: FixedMapSchema<dynamic>(
              keys: {
                strings.includeCStdLib: BoolSchema(
                  defaultValue: (node) => true,
                ),
              },
            )
          },
          transform: (node) => CompilerOptsAuto(
            macIncludeStdLib:
                (node.value)[strings.macos][strings.includeCStdLib] as bool,
          ),
          result: (node) => _compilerOpts
              .addAll((node.value as CompilerOptsAuto).extractCompilerOpts()),
        ),
        // TODO: needs custom validation like libraryImportsValidator
        strings.libraryImports: DynamicMapSchema<String>(
          keyValueSchemas: [
            (keyRegexp: ".*", valueSchema: StringSchema()),
          ],
          transform: (node) => libraryImportsExtractor(node.value.cast()),
          defaultValue: (node) => <String, LibraryImport>{},
          result: (node) =>
              _libraryImports = (node.value) as Map<String, LibraryImport>,
        ),
        strings.functions: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
            ...memberRenameProperties(),
            strings.symbolAddress: includeExcludeObject(),
            strings.exposeFunctionTypedefs: includeExcludeObject(
              defaultValue: (node) => Includer.excludeByDefault(),
            ),
            strings.leafFunctions: includeExcludeObject(
              defaultValue: (node) => Includer.excludeByDefault(),
            ),
            strings.varArgFunctions: DynamicMapSchema<dynamic>(
              keyValueSchemas: [
                (
                  keyRegexp: ".*",
                  valueSchema: ListSchema<dynamic>(
                    childSchema: OneOfSchema(
                      childSchemas: [
                        ListSchema<String>(childSchema: StringSchema()),
                        FixedMapSchema<dynamic>(
                          requiredKeys: [strings.types],
                          keys: {
                            strings.types:
                                ListSchema<String>(childSchema: StringSchema()),
                            strings.postfix: StringSchema(),
                          },
                        )
                      ],
                    ),
                  )
                )
              ],
              defaultValue: (node) => <String, List<RawVarArgFunction>>{},
              transform: (node) => varArgFunctionConfigExtractor(node.value),
              result: (node) {
                _varArgFunctions = makeVarArgFunctionsMapping(
                    node.value as Map<String, List<RawVarArgFunction>>,
                    _libraryImports);
              },
            )
          },
          result: (node) {
            _functionDecl =
                declarationConfigExtractor(node.rawValue ?? YamlMap());
            _exposeFunctionTypedefs =
                (node.value as Map)[strings.exposeFunctionTypedefs] as Includer;
            _leafFunctions =
                (node.value as Map)[strings.leafFunctions] as Includer;
          },
        ),
        strings.structs: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
            ...memberRenameProperties(),
            strings.dependencyOnly: dependencyOnlyObject(),
            strings.structPack: DynamicMapSchema<dynamic>(
              keyValueSchemas: [
                (
                  keyRegexp: '.*',
                  valueSchema: EnumSchema(
                    allowedValues: {'none', 1, 2, 4, 8, 16},
                    transform: (node) =>
                        node.value == 'none' ? null : node.value,
                  ),
                )
              ],
              transform: (node) => structPackingOverrideExtractor(node.value),
              defaultValue: (node) => StructPackingOverride(),
              result: (node) =>
                  _structPackingOverride = node.value as StructPackingOverride,
            )
          },
          result: (node) {
            _structDecl =
                declarationConfigExtractor(node.rawValue ?? YamlMap());
            _structDependencies = (node.value as Map)[strings.dependencyOnly]
                as CompoundDependencies;
          },
        ),
        strings.unions: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
            ...memberRenameProperties(),
            strings.dependencyOnly: dependencyOnlyObject(),
          },
          result: (node) {
            _unionDecl = declarationConfigExtractor(node.rawValue ?? YamlMap());
            _unionDependencies = (node.value as Map)[strings.dependencyOnly]
                as CompoundDependencies;
          },
        ),
        strings.enums: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
            ...memberRenameProperties(),
          },
          result: (node) {
            _enumClassDecl =
                declarationConfigExtractor(node.rawValue ?? YamlMap());
          },
        ),
        strings.unnamedEnums: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
          },
          result: (node) {
            _unnamedEnumConstants =
                declarationConfigExtractor(node.rawValue ?? YamlMap());
          },
        ),
        strings.globals: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
            strings.symbolAddress: includeExcludeObject(),
          },
          result: (node) {
            _globals = declarationConfigExtractor(node.rawValue ?? YamlMap());
          },
        ),
        strings.macros: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
          },
          result: (node) {
            _macroDecl = declarationConfigExtractor(node.rawValue ?? YamlMap());
          },
        ),
        strings.typedefs: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
          },
          result: (node) {
            _typedefs = declarationConfigExtractor(node.rawValue ?? YamlMap());
          },
        ),
        strings.objcInterfaces: FixedMapSchema<dynamic>(
          keys: {
            ...includeExcludeProperties(),
            ...renameProperties(),
            ...memberRenameProperties(),
            strings.objcModule: objcInterfaceModuleObject(),
          },
          result: (node) {
            _objcInterfaces =
                declarationConfigExtractor(node.rawValue ?? YamlMap());
            _objcModulePrefixer =
                (node.value as Map)[strings.objcModule] as ObjCModulePrefixer;
          },
        ),
        strings.import: FixedMapSchema<dynamic>(
          keys: {
            strings.symbolFilesImport: ListSchema<String>(
              childSchema: StringSchema(),
              transform: (node) => symbolFileImportExtractor(
                  node.value, _libraryImports, filename, packageConfig),
              defaultValue: (node) => <String, ImportedType>{},
              result: (node) =>
                  _usrTypeMappings = node.value as Map<String, ImportedType>,
            ),
          },
        ),
        strings.typeMap: FixedMapSchema<dynamic>(
          keys: {
            strings.typeMapTypedefs: mappedTypeObject(),
            strings.typeMapStructs: mappedTypeObject(),
            strings.typeMapUnions: mappedTypeObject(),
            strings.typeMapNativeTypes: mappedTypeObject(),
          },
          result: (node) {
            _typedefTypeMappings = makeImportTypeMapping(
              (node.value[strings.typeMapTypedefs])
                  as Map<String, List<String>>,
              _libraryImports,
            );
            _structTypeMappings = makeImportTypeMapping(
              (node.value[strings.typeMapStructs]) as Map<String, List<String>>,
              _libraryImports,
            );
            _unionTypeMappings = makeImportTypeMapping(
              (node.value[strings.typeMapUnions]) as Map<String, List<String>>,
              _libraryImports,
            );
            _nativeTypeMappings = makeImportTypeMapping(
              (node.value[strings.typeMapNativeTypes])
                  as Map<String, List<String>>,
              _libraryImports,
            );
          },
        ),
        strings.excludeAllByDefault: BoolSchema(
          defaultValue: (node) => false,
          result: (node) => _excludeAllByDefault = node.value as bool,
        ),
        strings.sort: BoolSchema(
          defaultValue: (node) => false,
          result: (node) => _sort = node.value as bool,
        ),
        strings.useSupportedTypedefs: BoolSchema(
          defaultValue: (node) => true,
          result: (node) => _useSupportedTypedefs = node.value as bool,
        ),
        strings.comments: OneOfSchema(
          childSchemas: [
            BoolSchema(
              transform: (node) =>
                  (node.value == true) ? CommentType.def() : CommentType.none(),
            ),
            FixedMapSchema<dynamic>(
              keys: {
                strings.style: EnumSchema(
                  allowedValues: {strings.doxygen, strings.any},
                  transform: (node) => node.value == strings.doxygen
                      ? CommentStyle.doxygen
                      : CommentStyle.any,
                  defaultValue: (node) => CommentStyle.doxygen,
                ),
                strings.length: EnumSchema(
                  allowedValues: {strings.brief, strings.full},
                  transform: (node) => node.value == strings.brief
                      ? CommentLength.brief
                      : CommentLength.full,
                  defaultValue: (node) => CommentLength.full,
                )
              },
              transform: (node) => CommentType(
                (node.value)[strings.style] as CommentStyle,
                (node.value)[strings.length] as CommentLength,
              ),
            ),
          ],
          defaultValue: (node) => CommentType.def(),
          result: (node) => _commentType = node.value as CommentType,
        ),
        strings.name: StringSchema(
          defaultValue: (node) {
            // TODO: replace dartClassNameValidator
            _logger.warning(
                "Prefer adding Key '${node.pathString}' to your config.");
            return 'NativeLibrary';
          },
          result: (node) => _wrapperName = node.value as String,
        ),
        strings.description: StringSchema(
          // TODO: replace nonEmptyStringValidator
          defaultValue: (node) {
            _logger.warning(
                "Prefer adding Key '${node.pathString}' to your config.");
            return null;
          },
          result: (node) => _wrapperDocComment = node.value as String?,
        ),
        strings.preamble: StringSchema(
          result: (node) => _preamble = node.value as String?,
        ),
        strings.useDartHandle: BoolSchema(
          defaultValue: (node) => true,
          result: (node) => _useDartHandle = node.value as bool,
        ),
        strings.ffiNative: OneOfSchema(
          childSchemas: [
            EnumSchema(allowedValues: {null}),
            FixedMapSchema<dynamic>(
              requiredKeys: [strings.ffiNativeAsset],
              keys: {
                strings.ffiNativeAsset: StringSchema(),
              },
            )
          ],
          transform: (node) => ffiNativeExtractor(node.value),
          defaultValue: (node) => FfiNativeConfig(enabled: false),
          result: (node) => _ffiNativeConfig = (node.value) as FfiNativeConfig,
        ),
      },
    );
  }

  Map<String, Schema> includeExcludeProperties() {
    return {
      strings.include: ListSchema<String>(
        schemaDefName: "include",
        childSchema: StringSchema(),
      ),
      strings.exclude: ListSchema<String>(
        schemaDefName: "exclude",
        childSchema: StringSchema(),
        defaultValue: (node) => <String>[],
      ),
    };
  }

  Map<String, Schema> renameProperties() {
    return {
      strings.rename: DynamicMapSchema<String>(
        schemaDefName: "rename",
        keyValueSchemas: [
          (keyRegexp: ".*", valueSchema: StringSchema()),
        ],
      ),
    };
  }

  Map<String, Schema> memberRenameProperties() {
    return {
      strings.memberRename: DynamicMapSchema<dynamic>(
        schemaDefName: "memberRename",
        keyValueSchemas: [
          (
            keyRegexp: ".*",
            valueSchema: DynamicMapSchema<String>(
              keyValueSchemas: [(keyRegexp: ".*", valueSchema: StringSchema())],
            ),
          ),
        ],
      ),
    };
  }

  FixedMapSchema<List<String>> includeExcludeObject(
      {dynamic Function(SchemaNode<void> node)? defaultValue}) {
    return FixedMapSchema<List<String>>(
      schemaDefName: "includeExclude",
      keys: {
        ...includeExcludeProperties(),
      },
      transform: (node) => extractIncluderFromYaml(node.rawValue ?? YamlMap()),
      defaultValue: defaultValue,
    );
  }

  EnumSchema dependencyOnlyObject() {
    return EnumSchema(
      schemaDefName: "dependencyOnly",
      allowedValues: {
        strings.fullCompoundDependencies,
        strings.opaqueCompoundDependencies,
      },
      defaultValue: (node) => CompoundDependencies.full,
      transform: (node) => node.value == strings.opaqueCompoundDependencies
          ? CompoundDependencies.opaque
          : CompoundDependencies.full,
    );
  }

  DynamicMapSchema mappedTypeObject() {
    return DynamicMapSchema(
      schemaDefName: "mappedTypes",
      keyValueSchemas: [
        (
          keyRegexp: ".*",
          valueSchema: FixedMapSchema<String>(
            requiredKeys: [strings.lib, strings.cType, strings.dartType],
            keys: {
              strings.lib: StringSchema(),
              strings.cType: StringSchema(),
              strings.dartType: StringSchema(),
            },
          )
        )
      ],
      defaultValue: (node) => <String, List<String>>{},
      transform: (node) => typeMapExtractor(node.value),
    );
  }

  DynamicMapSchema objcInterfaceModuleObject() {
    return DynamicMapSchema(
      schemaDefName: "objcInterfaceModule",
      keyValueSchemas: [
        (keyRegexp: ".*", valueSchema: StringSchema()),
      ],
      transform: (node) =>
          ObjCModulePrefixer(node.value.cast<String, String>()),
      defaultValue: (node) => ObjCModulePrefixer({}),
    );
  }
}
