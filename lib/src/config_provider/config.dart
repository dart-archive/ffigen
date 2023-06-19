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
    return FixedMapSchema(
      keys: [
        FixedMapKey(
          key: strings.llvmPath,
          valueSchema: ListSchema<String>(
            childSchema: StringSchema(),
            transform: (node) => llvmPathExtractor(node.value),
          ),
          defaultValue: (node) => findDylibAtDefaultLocations(),
          resultOrDefault: (node) => _libclangDylib = node.value as String,
        ),
        FixedMapKey(
            key: strings.output,
            required: true,
            valueSchema: OneOfSchema(
              childSchemas: [
                _filePathStringSchema(),
                _outputFullSchema(),
              ],
              transform: (node) =>
                  outputExtractor(node.value, filename, packageConfig),
              result: (node) {
                _output = (node.value as OutputConfig).output;
                _symbolFile = (node.value as OutputConfig).symbolFile;
              },
            )),
        FixedMapKey(
          key: strings.language,
          valueSchema: EnumSchema(
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
          ),
          defaultValue: (node) => Language.c,
          resultOrDefault: (node) => _language = node.value as Language,
        ),
        FixedMapKey(
            key: strings.headers,
            required: true,
            valueSchema: FixedMapSchema<List<String>>(
              keys: [
                FixedMapKey(
                  key: strings.entryPoints,
                  valueSchema: ListSchema<String>(childSchema: StringSchema()),
                  required: true,
                ),
                FixedMapKey(
                  key: strings.includeDirectives,
                  valueSchema: ListSchema<String>(childSchema: StringSchema()),
                ),
              ],
              transform: (node) => headersExtractor(node.value, filename),
              result: (node) => _headers = node.value as Headers,
            )),
        FixedMapKey(
          key: strings.compilerOpts,
          valueSchema: OneOfSchema(
            childSchemas: [
              StringSchema(),
              ListSchema<String>(childSchema: StringSchema())
            ],
            transform: (node) => compilerOptsExtractor(node.value),
          ),
          defaultValue: (node) => <String>[],
          resultOrDefault: (node) => _compilerOpts = node.value as List<String>,
        ),
        FixedMapKey(
            key: strings.compilerOptsAuto,
            valueSchema: FixedMapSchema<dynamic>(
              keys: [
                FixedMapKey(
                  key: strings.macos,
                  valueSchema: FixedMapSchema(
                    keys: [
                      FixedMapKey(
                        key: strings.includeCStdLib,
                        valueSchema: BoolSchema(),
                        defaultValue: (node) => true,
                      )
                    ],
                  ),
                )
              ],
              transform: (node) => CompilerOptsAuto(
                macIncludeStdLib: (node.value)[strings.macos]
                    ?[strings.includeCStdLib] as bool,
              ),
              result: (node) => _compilerOpts.addAll(
                  (node.value as CompilerOptsAuto).extractCompilerOpts()),
            )),
        // TODO: needs custom validation like libraryImportsValidator
        FixedMapKey(
          key: strings.libraryImports,
          valueSchema: DynamicMapSchema<String>(
            keyValueSchemas: [
              (keyRegexp: ".*", valueSchema: StringSchema()),
            ],
            customValidation: _libraryImportsPredefinedValidation,
            transform: (node) => libraryImportsExtractor(node.value.cast()),
          ),
          defaultValue: (node) => <String, LibraryImport>{},
          resultOrDefault: (node) =>
              _libraryImports = (node.value) as Map<String, LibraryImport>,
        ),
        FixedMapKey(
            key: strings.functions,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                FixedMapKey(
                  key: strings.symbolAddress,
                  valueSchema: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                ),
                FixedMapKey(
                  key: strings.exposeFunctionTypedefs,
                  valueSchema: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                ),
                FixedMapKey(
                  key: strings.leafFunctions,
                  valueSchema: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                ),
                FixedMapKey(
                  key: strings.varArgFunctions,
                  valueSchema: _functionVarArgsSchema(),
                  defaultValue: (node) => <String, List<RawVarArgFunction>>{},
                  resultOrDefault: (node) {
                    _varArgFunctions = makeVarArgFunctionsMapping(
                        node.value as Map<String, List<RawVarArgFunction>>,
                        _libraryImports);
                  },
                ),
              ],
              result: (node) {
                _functionDecl =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
                _exposeFunctionTypedefs = (node.value
                    as Map)[strings.exposeFunctionTypedefs] as Includer;
                _leafFunctions =
                    (node.value as Map)[strings.leafFunctions] as Includer;
              },
            )),
        FixedMapKey(
            key: strings.structs,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                _dependencyOnlyFixedMapKey(),
                FixedMapKey(
                  key: strings.structPack,
                  valueSchema: DynamicMapSchema(
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
                    transform: (node) =>
                        structPackingOverrideExtractor(node.value),
                  ),
                  defaultValue: (node) => StructPackingOverride(),
                  resultOrDefault: (node) => _structPackingOverride =
                      node.value as StructPackingOverride,
                ),
              ],
              result: (node) {
                _structDecl =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
                _structDependencies = (node.value
                    as Map)[strings.dependencyOnly] as CompoundDependencies;
              },
            )),
        FixedMapKey(
            key: strings.unions,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                _dependencyOnlyFixedMapKey(),
              ],
              result: (node) {
                _unionDecl =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
                _unionDependencies = (node.value as Map)[strings.dependencyOnly]
                    as CompoundDependencies;
              },
            )),
        FixedMapKey(
            key: strings.enums,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
              ],
              result: (node) {
                _enumClassDecl =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
              },
            )),
        FixedMapKey(
            key: strings.unnamedEnums,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
              ],
              result: (node) {
                _unnamedEnumConstants =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
              },
            )),
        FixedMapKey(
            key: strings.globals,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                FixedMapKey(
                  key: strings.symbolAddress,
                  valueSchema: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                )
              ],
              result: (node) {
                _globals =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
              },
            )),
        FixedMapKey(
            key: strings.macros,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
              ],
              result: (node) {
                _macroDecl =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
              },
            )),
        FixedMapKey(
            key: strings.typedefs,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
              ],
              result: (node) {
                _typedefs =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
              },
            )),
        FixedMapKey(
            key: strings.objcInterfaces,
            valueSchema: FixedMapSchema(
              keys: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                FixedMapKey(
                  key: strings.objcModule,
                  valueSchema: _objcInterfaceModuleObject(),
                  defaultValue: (node) => ObjCModulePrefixer({}),
                )
              ],
              result: (node) {
                _objcInterfaces =
                    declarationConfigExtractor(node.rawValue ?? YamlMap());
                _objcModulePrefixer = (node.value as Map)[strings.objcModule]
                    as ObjCModulePrefixer;
              },
            )),
        FixedMapKey(
            key: strings.import,
            valueSchema: FixedMapSchema(
              keys: [
                FixedMapKey(
                  key: strings.symbolFilesImport,
                  valueSchema: ListSchema<String>(
                    childSchema: StringSchema(),
                    transform: (node) => symbolFileImportExtractor(
                        node.value, _libraryImports, filename, packageConfig),
                  ),
                  defaultValue: (node) => <String, ImportedType>{},
                  resultOrDefault: (node) => _usrTypeMappings =
                      node.value as Map<String, ImportedType>,
                )
              ],
            )),
        FixedMapKey(
            key: strings.typeMap,
            valueSchema: FixedMapSchema(
              keys: [
                FixedMapKey(
                  key: strings.typeMapTypedefs,
                  valueSchema: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
                FixedMapKey(
                  key: strings.typeMapStructs,
                  valueSchema: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
                FixedMapKey(
                  key: strings.typeMapUnions,
                  valueSchema: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
                FixedMapKey(
                  key: strings.typeMapNativeTypes,
                  valueSchema: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
              ],
              result: (node) {
                _typedefTypeMappings = makeImportTypeMapping(
                  (node.value[strings.typeMapTypedefs])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
                _structTypeMappings = makeImportTypeMapping(
                  (node.value[strings.typeMapStructs])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
                _unionTypeMappings = makeImportTypeMapping(
                  (node.value[strings.typeMapUnions])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
                _nativeTypeMappings = makeImportTypeMapping(
                  (node.value[strings.typeMapNativeTypes])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
              },
            )),
        FixedMapKey(
          key: strings.excludeAllByDefault,
          valueSchema: BoolSchema(),
          defaultValue: (node) => false,
          resultOrDefault: (node) => _excludeAllByDefault = node.value as bool,
        ),
        FixedMapKey(
          key: strings.sort,
          valueSchema: BoolSchema(),
          defaultValue: (node) => false,
          resultOrDefault: (node) => _sort = node.value as bool,
        ),
        FixedMapKey(
          key: strings.useSupportedTypedefs,
          valueSchema: BoolSchema(),
          defaultValue: (node) => true,
          resultOrDefault: (node) => _useSupportedTypedefs = node.value as bool,
        ),
        FixedMapKey(
          key: strings.comments,
          valueSchema: _commentSchema(),
          defaultValue: (node) => CommentType.def(),
          resultOrDefault: (node) => _commentType = node.value as CommentType,
        ),
        FixedMapKey(
          key: strings.name,
          valueSchema: _dartClassNameStringSchema(),
          defaultValue: (node) {
            _logger.warning(
                "Prefer adding Key '${node.pathString}' to your config.");
            return 'NativeLibrary';
          },
          resultOrDefault: (node) => _wrapperName = node.value as String,
        ),
        FixedMapKey(
          key: strings.description,
          valueSchema: _nonEmptyStringSchema(),
          defaultValue: (node) {
            _logger.warning(
                "Prefer adding Key '${node.pathString}' to your config.");
            return null;
          },
          resultOrDefault: (node) => _wrapperDocComment = node.value as String?,
        ),
        FixedMapKey(
            key: strings.preamble,
            valueSchema: StringSchema(
              result: (node) => _preamble = node.value as String?,
            )),
        FixedMapKey(
          key: strings.useDartHandle,
          valueSchema: BoolSchema(),
          defaultValue: (node) => true,
          resultOrDefault: (node) => _useDartHandle = node.value as bool,
        ),
        FixedMapKey(
          key: strings.ffiNative,
          valueSchema: OneOfSchema(
            childSchemas: [
              EnumSchema(allowedValues: {null}),
              FixedMapSchema(
                keys: [
                  FixedMapKey(
                    key: strings.ffiNativeAsset,
                    valueSchema: StringSchema(),
                    required: true,
                  )
                ],
              )
            ],
            transform: (node) => ffiNativeExtractor(node.value),
          ),
          defaultValue: (node) => FfiNativeConfig(enabled: false),
          resultOrDefault: (node) =>
              _ffiNativeConfig = (node.value) as FfiNativeConfig,
        ),
      ],
    );
  }

  bool _libraryImportsPredefinedValidation(SchemaNode node) {
    if (node.value is YamlMap) {
      return (node.value as YamlMap).keys.where((key) {
        if (strings.predefinedLibraryImports.containsKey(key)) {
          _logger.severe(
              '${node.pathString} -> $key should not collide with any predefined imports - ${strings.predefinedLibraryImports.keys}.');
          return true;
        }
        return false;
      }).isEmpty;
    }
    return true;
  }

  OneOfSchema<dynamic> _commentSchema() {
    return OneOfSchema(
      childSchemas: [
        BoolSchema(
          transform: (node) =>
              (node.value == true) ? CommentType.def() : CommentType.none(),
        ),
        FixedMapSchema(
          keys: [
            FixedMapKey(
              key: strings.style,
              valueSchema: EnumSchema(
                allowedValues: {strings.doxygen, strings.any},
                transform: (node) => node.value == strings.doxygen
                    ? CommentStyle.doxygen
                    : CommentStyle.any,
              ),
              defaultValue: (node) => CommentStyle.doxygen,
            ),
            FixedMapKey(
              key: strings.length,
              valueSchema: EnumSchema(
                allowedValues: {strings.brief, strings.full},
                transform: (node) => node.value == strings.brief
                    ? CommentLength.brief
                    : CommentLength.full,
              ),
              defaultValue: (node) => CommentLength.full,
            ),
          ],
          transform: (node) => CommentType(
            (node.value)[strings.style] as CommentStyle,
            (node.value)[strings.length] as CommentLength,
          ),
        ),
      ],
    );
  }

  DynamicMapSchema<Object?> _functionVarArgsSchema() {
    return DynamicMapSchema(
      keyValueSchemas: [
        (
          keyRegexp: ".*",
          valueSchema: ListSchema(
            childSchema: OneOfSchema(
              childSchemas: [
                ListSchema<String>(childSchema: StringSchema()),
                FixedMapSchema(
                  keys: [
                    FixedMapKey(
                      key: strings.types,
                      valueSchema:
                          ListSchema<String>(childSchema: StringSchema()),
                      required: true,
                    ),
                    FixedMapKey(
                      key: strings.postfix,
                      valueSchema: StringSchema(),
                    ),
                  ],
                )
              ],
            ),
          )
        )
      ],
      transform: (node) => varArgFunctionConfigExtractor(node.value),
    );
  }

  FixedMapSchema<dynamic> _outputFullSchema() {
    return FixedMapSchema(
      keys: [
        FixedMapKey(
          key: strings.bindings,
          valueSchema: _filePathStringSchema(),
          required: true,
        ),
        FixedMapKey(
          key: strings.symbolFile,
          valueSchema: FixedMapSchema<String>(
            keys: [
              FixedMapKey(
                key: strings.output,
                valueSchema: _filePathStringSchema(),
                required: true,
              ),
              FixedMapKey(
                key: strings.importPath,
                valueSchema: StringSchema(),
                required: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  StringSchema _filePathStringSchema() {
    return StringSchema(
      schemaDefName: 'filePath',
      schemaDescription: "A file path",
    );
  }

  StringSchema _nonEmptyStringSchema() {
    return StringSchema(
      schemaDefName: 'nonEmptyString',
      pattern: r'.+',
    );
  }

  StringSchema _dartClassNameStringSchema() {
    return StringSchema(
      schemaDefName: 'publicDartClass',
      schemaDescription: "A public dart class name.",
      pattern: r'^[a-zA-Z]+[_a-zA-Z0-9]*$',
    );
  }

  List<FixedMapKey> _includeExcludeProperties() {
    return [
      FixedMapKey(
        key: strings.include,
        valueSchema: _fullMatchOrRegexpList(),
      ),
      FixedMapKey(
        key: strings.exclude,
        valueSchema: _fullMatchOrRegexpList(),
        defaultValue: (node) => <String>[],
      ),
    ];
  }

  ListSchema<String> _fullMatchOrRegexpList() {
    return ListSchema<String>(
      schemaDefName: "fullMatchOrRegexpList",
      childSchema: StringSchema(),
    );
  }

  List<FixedMapKey> _renameProperties() {
    return [
      FixedMapKey(
        key: strings.rename,
        valueSchema: DynamicMapSchema<String>(
          schemaDefName: "rename",
          keyValueSchemas: [
            (keyRegexp: ".*", valueSchema: StringSchema()),
          ],
        ),
      ),
    ];
  }

  List<FixedMapKey> _memberRenameProperties() {
    return [
      FixedMapKey(
        key: strings.memberRename,
        valueSchema: DynamicMapSchema(
          schemaDefName: "memberRename",
          keyValueSchemas: [
            (
              keyRegexp: ".*",
              valueSchema: DynamicMapSchema<String>(
                keyValueSchemas: [
                  (keyRegexp: ".*", valueSchema: StringSchema())
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  FixedMapSchema<List<String>> _includeExcludeObject() {
    return FixedMapSchema<List<String>>(
      schemaDefName: "includeExclude",
      keys: [
        ..._includeExcludeProperties(),
      ],
      transform: (node) => extractIncluderFromYaml(node.rawValue ?? YamlMap()),
    );
  }

  FixedMapKey _dependencyOnlyFixedMapKey() {
    return FixedMapKey(
      key: strings.dependencyOnly,
      valueSchema: EnumSchema(
        schemaDefName: "dependencyOnly",
        allowedValues: {
          strings.fullCompoundDependencies,
          strings.opaqueCompoundDependencies,
        },
        transform: (node) => node.value == strings.opaqueCompoundDependencies
            ? CompoundDependencies.opaque
            : CompoundDependencies.full,
      ),
      defaultValue: (node) => CompoundDependencies.full,
    );
  }

  DynamicMapSchema _mappedTypeObject() {
    return DynamicMapSchema(
      schemaDefName: "mappedTypes",
      keyValueSchemas: [
        (
          keyRegexp: ".*",
          valueSchema: FixedMapSchema<String>(keys: [
            FixedMapKey(key: strings.lib, valueSchema: StringSchema()),
            FixedMapKey(key: strings.cType, valueSchema: StringSchema()),
            FixedMapKey(key: strings.dartType, valueSchema: StringSchema()),
          ]),
        )
      ],
      transform: (node) => typeMapExtractor(node.value),
    );
  }

  DynamicMapSchema _objcInterfaceModuleObject() {
    return DynamicMapSchema(
      schemaDefName: "objcInterfaceModule",
      keyValueSchemas: [
        (keyRegexp: ".*", valueSchema: StringSchema()),
      ],
      transform: (node) =>
          ObjCModulePrefixer(node.value.cast<String, String>()),
    );
  }
}
