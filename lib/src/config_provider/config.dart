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
import 'config_spec.dart';
import 'config_types.dart';
import 'spec_utils.dart';

final _logger = Logger('ffigen.config_provider.config');

/// Provides configurations to other modules.
///
/// Handles validation, extraction of configurations from a yaml file.
class Config {
  /// Input filename.
  final String? filename;

  /// Package config.
  final PackageConfig? packageConfig;

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

  Config._({required this.filename, required this.packageConfig});

  /// Create config from Yaml map.
  factory Config.fromYaml(YamlMap map,
      {String? filename, PackageConfig? packageConfig}) {
    final config = Config._(filename: filename, packageConfig: packageConfig);
    _logger.finest('Config Map: $map');

    final ffigenSchema = config._getRootSchema();
    final result = ffigenSchema.validate(map);
    if (!result) {
      throw FormatException('Invalid configurations provided.');
    }

    ffigenSchema.extract(map);
    return config;
  }

  /// Create config from a file.
  factory Config.fromFile(File file, {PackageConfig? packageConfig}) {
    // Throws a [YamlException] if it's unable to parse the Yaml.
    final configYaml = loadYaml(file.readAsStringSync()) as YamlMap;

    return Config.fromYaml(configYaml,
        filename: file.path, packageConfig: packageConfig);
  }

  /// Returns the root Schema object.
  static ConfigSpec getsRootSchema() {
    final configspecs = Config._(filename: null, packageConfig: null);
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

  ConfigSpec _getRootSchema() {
    return FixedMapConfigSpec(
      entries: [
        FixedMapEntry(
          key: strings.llvmPath,
          valueConfigSpec: ListSchema<String>(
            childSchema: StringConfigSpec(),
            transform: (node) => llvmPathExtractor(node.value),
          ),
          defaultValue: (node) => findDylibAtDefaultLocations(),
          resultOrDefault: (node) => _libclangDylib = node.value as String,
        ),
        FixedMapEntry(
            key: strings.output,
            required: true,
            valueConfigSpec: OneOfConfigSpec(
              childConfigSpecs: [
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
        FixedMapEntry(
          key: strings.language,
          valueConfigSpec: EnumConfigSpec(
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
        FixedMapEntry(
            key: strings.headers,
            required: true,
            valueConfigSpec: FixedMapConfigSpec<List<String>>(
              entries: [
                FixedMapEntry(
                  key: strings.entryPoints,
                  valueConfigSpec:
                      ListSchema<String>(childSchema: StringConfigSpec()),
                  required: true,
                ),
                FixedMapEntry(
                  key: strings.includeDirectives,
                  valueConfigSpec:
                      ListSchema<String>(childSchema: StringConfigSpec()),
                ),
              ],
              transform: (node) => headersExtractor(node.value, filename),
              result: (node) => _headers = node.value as Headers,
            )),
        FixedMapEntry(
          key: strings.compilerOpts,
          valueConfigSpec: OneOfConfigSpec<List<String>>(
            childConfigSpecs: [
              StringConfigSpec(
                transform: (node) => [node.value],
              ),
              ListSchema<String>(childSchema: StringConfigSpec())
            ],
            transform: (node) => compilerOptsExtractor(node.value),
          ),
          defaultValue: (node) => <String>[],
          resultOrDefault: (node) => _compilerOpts = node.value as List<String>,
        ),
        FixedMapEntry(
            key: strings.compilerOptsAuto,
            valueConfigSpec: FixedMapConfigSpec<dynamic>(
              entries: [
                FixedMapEntry(
                  key: strings.macos,
                  valueConfigSpec: FixedMapConfigSpec(
                    entries: [
                      FixedMapEntry(
                        key: strings.includeCStdLib,
                        valueConfigSpec: BoolConfigSpec(),
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
        FixedMapEntry(
          key: strings.libraryImports,
          valueConfigSpec: DynamicMapConfigSpec<String>(
            keyValueConfigSpecs: [
              (keyRegexp: ".*", valueConfigSpec: StringConfigSpec()),
            ],
            customValidation: _libraryImportsPredefinedValidation,
            transform: (node) => libraryImportsExtractor(node.value.cast()),
          ),
          defaultValue: (node) => <String, LibraryImport>{},
          resultOrDefault: (node) =>
              _libraryImports = (node.value) as Map<String, LibraryImport>,
        ),
        FixedMapEntry(
            key: strings.functions,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                FixedMapEntry(
                  key: strings.symbolAddress,
                  valueConfigSpec: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                ),
                FixedMapEntry(
                  key: strings.exposeFunctionTypedefs,
                  valueConfigSpec: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                ),
                FixedMapEntry(
                  key: strings.leafFunctions,
                  valueConfigSpec: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                ),
                FixedMapEntry(
                  key: strings.varArgFunctions,
                  valueConfigSpec: _functionVarArgsSchema(),
                  defaultValue: (node) => <String, List<RawVarArgFunction>>{},
                  resultOrDefault: (node) {
                    _varArgFunctions = makeVarArgFunctionsMapping(
                        node.value as Map<String, List<RawVarArgFunction>>,
                        _libraryImports);
                  },
                ),
              ],
              result: (node) {
                _functionDecl = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
                _exposeFunctionTypedefs = (node.value
                    as Map)[strings.exposeFunctionTypedefs] as Includer;
                _leafFunctions =
                    (node.value as Map)[strings.leafFunctions] as Includer;
              },
            )),
        FixedMapEntry(
            key: strings.structs,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                _dependencyOnlyFixedMapKey(),
                FixedMapEntry(
                  key: strings.structPack,
                  valueConfigSpec: DynamicMapConfigSpec(
                    keyValueConfigSpecs: [
                      (
                        keyRegexp: '.*',
                        valueConfigSpec: EnumConfigSpec(
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
                _structDecl = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
                _structDependencies = (node.value
                    as Map)[strings.dependencyOnly] as CompoundDependencies;
              },
            )),
        FixedMapEntry(
            key: strings.unions,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                _dependencyOnlyFixedMapKey(),
              ],
              result: (node) {
                _unionDecl = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
                _unionDependencies = (node.value as Map)[strings.dependencyOnly]
                    as CompoundDependencies;
              },
            )),
        FixedMapEntry(
            key: strings.enums,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
              ],
              result: (node) {
                _enumClassDecl = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
              },
            )),
        FixedMapEntry(
            key: strings.unnamedEnums,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
              ],
              result: (node) {
                _unnamedEnumConstants = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
              },
            )),
        FixedMapEntry(
            key: strings.globals,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                FixedMapEntry(
                  key: strings.symbolAddress,
                  valueConfigSpec: _includeExcludeObject(),
                  defaultValue: (node) => Includer.excludeByDefault(),
                )
              ],
              result: (node) {
                _globals = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
              },
            )),
        FixedMapEntry(
            key: strings.macros,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
              ],
              result: (node) {
                _macroDecl = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
              },
            )),
        FixedMapEntry(
            key: strings.typedefs,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
              ],
              result: (node) {
                _typedefs = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
              },
            )),
        FixedMapEntry(
            key: strings.objcInterfaces,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                ..._includeExcludeProperties(),
                ..._renameProperties(),
                ..._memberRenameProperties(),
                FixedMapEntry(
                  key: strings.objcModule,
                  valueConfigSpec: _objcInterfaceModuleObject(),
                  defaultValue: (node) => ObjCModulePrefixer({}),
                )
              ],
              result: (node) {
                _objcInterfaces = declarationConfigExtractor(
                    node.value as Map<dynamic, dynamic>);
                _objcModulePrefixer = (node.value as Map)[strings.objcModule]
                    as ObjCModulePrefixer;
              },
            )),
        FixedMapEntry(
            key: strings.import,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                FixedMapEntry(
                  key: strings.symbolFilesImport,
                  valueConfigSpec: ListSchema<String>(
                    childSchema: StringConfigSpec(),
                    transform: (node) => symbolFileImportExtractor(
                        node.value, _libraryImports, filename, packageConfig),
                  ),
                  defaultValue: (node) => <String, ImportedType>{},
                  resultOrDefault: (node) => _usrTypeMappings =
                      node.value as Map<String, ImportedType>,
                )
              ],
            )),
        FixedMapEntry(
            key: strings.typeMap,
            valueConfigSpec: FixedMapConfigSpec(
              entries: [
                FixedMapEntry(
                  key: strings.typeMapTypedefs,
                  valueConfigSpec: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
                FixedMapEntry(
                  key: strings.typeMapStructs,
                  valueConfigSpec: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
                FixedMapEntry(
                  key: strings.typeMapUnions,
                  valueConfigSpec: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
                FixedMapEntry(
                  key: strings.typeMapNativeTypes,
                  valueConfigSpec: _mappedTypeObject(),
                  defaultValue: (node) => <String, List<String>>{},
                ),
              ],
              result: (node) {
                final nodeValue = node.value as Map;
                _typedefTypeMappings = makeImportTypeMapping(
                  (nodeValue[strings.typeMapTypedefs])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
                _structTypeMappings = makeImportTypeMapping(
                  (nodeValue[strings.typeMapStructs])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
                _unionTypeMappings = makeImportTypeMapping(
                  (nodeValue[strings.typeMapUnions])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
                _nativeTypeMappings = makeImportTypeMapping(
                  (nodeValue[strings.typeMapNativeTypes])
                      as Map<String, List<String>>,
                  _libraryImports,
                );
              },
            )),
        FixedMapEntry(
          key: strings.excludeAllByDefault,
          valueConfigSpec: BoolConfigSpec(),
          defaultValue: (node) => false,
          resultOrDefault: (node) => _excludeAllByDefault = node.value as bool,
        ),
        FixedMapEntry(
          key: strings.sort,
          valueConfigSpec: BoolConfigSpec(),
          defaultValue: (node) => false,
          resultOrDefault: (node) => _sort = node.value as bool,
        ),
        FixedMapEntry(
          key: strings.useSupportedTypedefs,
          valueConfigSpec: BoolConfigSpec(),
          defaultValue: (node) => true,
          resultOrDefault: (node) => _useSupportedTypedefs = node.value as bool,
        ),
        FixedMapEntry(
          key: strings.comments,
          valueConfigSpec: _commentSchema(),
          defaultValue: (node) => CommentType.def(),
          resultOrDefault: (node) => _commentType = node.value as CommentType,
        ),
        FixedMapEntry(
          key: strings.name,
          valueConfigSpec: _dartClassNameStringSchema(),
          defaultValue: (node) {
            _logger.warning(
                "Prefer adding Key '${node.pathString}' to your config.");
            return 'NativeLibrary';
          },
          resultOrDefault: (node) => _wrapperName = node.value as String,
        ),
        FixedMapEntry(
          key: strings.description,
          valueConfigSpec: _nonEmptyStringSchema(),
          defaultValue: (node) {
            _logger.warning(
                "Prefer adding Key '${node.pathString}' to your config.");
            return null;
          },
          resultOrDefault: (node) => _wrapperDocComment = node.value as String?,
        ),
        FixedMapEntry(
            key: strings.preamble,
            valueConfigSpec: StringConfigSpec(
              result: (node) => _preamble = node.value as String?,
            )),
        FixedMapEntry(
          key: strings.useDartHandle,
          valueConfigSpec: BoolConfigSpec(),
          defaultValue: (node) => true,
          resultOrDefault: (node) => _useDartHandle = node.value as bool,
        ),
        FixedMapEntry(
          key: strings.ffiNative,
          valueConfigSpec: OneOfConfigSpec(
            childConfigSpecs: [
              EnumConfigSpec(allowedValues: {null}),
              FixedMapConfigSpec(
                entries: [
                  FixedMapEntry(
                    key: strings.ffiNativeAsset,
                    valueConfigSpec: StringConfigSpec(),
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

  bool _libraryImportsPredefinedValidation(ConfigSpecNode node) {
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

  OneOfConfigSpec<dynamic> _commentSchema() {
    return OneOfConfigSpec(
      childConfigSpecs: [
        BoolConfigSpec(
          transform: (node) =>
              (node.value == true) ? CommentType.def() : CommentType.none(),
        ),
        FixedMapConfigSpec(
          entries: [
            FixedMapEntry(
              key: strings.style,
              valueConfigSpec: EnumConfigSpec(
                allowedValues: {strings.doxygen, strings.any},
                transform: (node) => node.value == strings.doxygen
                    ? CommentStyle.doxygen
                    : CommentStyle.any,
              ),
              defaultValue: (node) => CommentStyle.doxygen,
            ),
            FixedMapEntry(
              key: strings.length,
              valueConfigSpec: EnumConfigSpec(
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

  DynamicMapConfigSpec<Object?> _functionVarArgsSchema() {
    return DynamicMapConfigSpec(
      keyValueConfigSpecs: [
        (
          keyRegexp: ".*",
          valueConfigSpec: ListSchema(
            childSchema: OneOfConfigSpec(
              childConfigSpecs: [
                ListSchema<String>(childSchema: StringConfigSpec()),
                FixedMapConfigSpec(
                  entries: [
                    FixedMapEntry(
                      key: strings.types,
                      valueConfigSpec:
                          ListSchema<String>(childSchema: StringConfigSpec()),
                      required: true,
                    ),
                    FixedMapEntry(
                      key: strings.postfix,
                      valueConfigSpec: StringConfigSpec(),
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

  FixedMapConfigSpec<dynamic> _outputFullSchema() {
    return FixedMapConfigSpec(
      entries: [
        FixedMapEntry(
          key: strings.bindings,
          valueConfigSpec: _filePathStringSchema(),
          required: true,
        ),
        FixedMapEntry(
          key: strings.symbolFile,
          valueConfigSpec: FixedMapConfigSpec<String>(
            entries: [
              FixedMapEntry(
                key: strings.output,
                valueConfigSpec: _filePathStringSchema(),
                required: true,
              ),
              FixedMapEntry(
                key: strings.importPath,
                valueConfigSpec: StringConfigSpec(),
                required: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  StringConfigSpec _filePathStringSchema() {
    return StringConfigSpec(
      schemaDefName: 'filePath',
      schemaDescription: "A file path",
    );
  }

  StringConfigSpec _nonEmptyStringSchema() {
    return StringConfigSpec(
      schemaDefName: 'nonEmptyString',
      pattern: r'.+',
    );
  }

  StringConfigSpec _dartClassNameStringSchema() {
    return StringConfigSpec(
      schemaDefName: 'publicDartClass',
      schemaDescription: "A public dart class name.",
      pattern: r'^[a-zA-Z]+[_a-zA-Z0-9]*$',
    );
  }

  List<FixedMapEntry> _includeExcludeProperties() {
    return [
      FixedMapEntry(
        key: strings.include,
        valueConfigSpec: _fullMatchOrRegexpList(),
      ),
      FixedMapEntry(
        key: strings.exclude,
        valueConfigSpec: _fullMatchOrRegexpList(),
        defaultValue: (node) => <String>[],
      ),
    ];
  }

  ListSchema<String> _fullMatchOrRegexpList() {
    return ListSchema<String>(
      schemaDefName: "fullMatchOrRegexpList",
      childSchema: StringConfigSpec(),
    );
  }

  List<FixedMapEntry> _renameProperties() {
    return [
      FixedMapEntry(
        key: strings.rename,
        valueConfigSpec: DynamicMapConfigSpec<String>(
          schemaDefName: "rename",
          keyValueConfigSpecs: [
            (keyRegexp: ".*", valueConfigSpec: StringConfigSpec()),
          ],
        ),
      ),
    ];
  }

  List<FixedMapEntry> _memberRenameProperties() {
    return [
      FixedMapEntry(
        key: strings.memberRename,
        valueConfigSpec: DynamicMapConfigSpec<Map<dynamic, String>>(
          schemaDefName: "memberRename",
          keyValueConfigSpecs: [
            (
              keyRegexp: ".*",
              valueConfigSpec: DynamicMapConfigSpec<String>(
                keyValueConfigSpecs: [
                  (keyRegexp: ".*", valueConfigSpec: StringConfigSpec())
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  FixedMapConfigSpec<List<String>> _includeExcludeObject() {
    return FixedMapConfigSpec<List<String>>(
      schemaDefName: "includeExclude",
      entries: [
        ..._includeExcludeProperties(),
      ],
      transform: (node) => extractIncluderFromYaml(node.value),
    );
  }

  FixedMapEntry _dependencyOnlyFixedMapKey() {
    return FixedMapEntry(
      key: strings.dependencyOnly,
      valueConfigSpec: EnumConfigSpec(
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

  DynamicMapConfigSpec _mappedTypeObject() {
    return DynamicMapConfigSpec(
      schemaDefName: "mappedTypes",
      keyValueConfigSpecs: [
        (
          keyRegexp: ".*",
          valueConfigSpec: FixedMapConfigSpec<String>(entries: [
            FixedMapEntry(
                key: strings.lib, valueConfigSpec: StringConfigSpec()),
            FixedMapEntry(
                key: strings.cType, valueConfigSpec: StringConfigSpec()),
            FixedMapEntry(
                key: strings.dartType, valueConfigSpec: StringConfigSpec()),
          ]),
        )
      ],
      transform: (node) => typeMapExtractor(node.value),
    );
  }

  DynamicMapConfigSpec _objcInterfaceModuleObject() {
    return DynamicMapConfigSpec(
      schemaDefName: "objcInterfaceModule",
      keyValueConfigSpecs: [
        (keyRegexp: ".*", valueConfigSpec: StringConfigSpec()),
      ],
      transform: (node) =>
          ObjCModulePrefixer(node.value.cast<String, String>()),
    );
  }
}
