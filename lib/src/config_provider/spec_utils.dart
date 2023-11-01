// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/utils.dart';
import 'package:ffigen/src/header_parser/type_extractor/cxtypekindmap.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/pattern.dart' as quiver;
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import 'config_types.dart';

final _logger = Logger('ffigen.config_provider.spec_utils');

/// Replaces the path separators according to current platform.
String _replaceSeparators(String path) {
  if (Platform.isWindows) {
    return path.replaceAll(p.posix.separator, p.windows.separator);
  } else {
    return path.replaceAll(p.windows.separator, p.posix.separator);
  }
}

/// Replaces the path separators according to current platform. If a relative
/// path is passed in, it is resolved relative to the config path, and the
/// absolute path is returned.
String _normalizePath(String path, String? configFilename) {
  final skipNormalization =
      (configFilename == null) || p.isAbsolute(path) || path.startsWith("**");
  return _replaceSeparators(
      skipNormalization ? path : p.join(p.dirname(configFilename), path));
}

Map<String, LibraryImport> libraryImportsExtractor(
    Map<String, String>? typeMap) {
  final resultMap = <String, LibraryImport>{};
  if (typeMap != null) {
    for (final typeName in typeMap.keys) {
      resultMap[typeName] =
          LibraryImport(typeName, typeMap[typeName] as String);
    }
  }
  return resultMap;
}

void loadImportedTypes(YamlMap fileConfig,
    Map<String, ImportedType> usrTypeMappings, LibraryImport libraryImport) {
  final symbols = fileConfig['symbols'] as YamlMap;
  for (final key in symbols.keys) {
    final usr = key as String;
    final value = symbols[usr]! as YamlMap;
    usrTypeMappings[usr] = ImportedType(
        libraryImport, value['name'] as String, value['name'] as String);
  }
}

YamlMap loadSymbolFile(String symbolFilePath, String? configFileName,
    PackageConfig? packageConfig) {
  final path = symbolFilePath.startsWith('package:')
      ? packageConfig!.resolve(Uri.parse(symbolFilePath))!.toFilePath()
      : _normalizePath(symbolFilePath, configFileName);

  return loadYaml(File(path).readAsStringSync()) as YamlMap;
}

Map<String, ImportedType> symbolFileImportExtractor(
    List<String> yamlConfig,
    Map<String, LibraryImport> libraryImports,
    String? configFileName,
    PackageConfig? packageConfig) {
  final resultMap = <String, ImportedType>{};
  for (final item in yamlConfig) {
    String symbolFilePath;
    symbolFilePath = item;
    final symbolFile =
        loadSymbolFile(symbolFilePath, configFileName, packageConfig);
    final formatVersion = symbolFile[strings.formatVersion] as String;
    if (formatVersion.split('.')[0] !=
        strings.symbolFileFormatVersion.split('.')[0]) {
      _logger.severe(
          'Incompatible format versions for file $symbolFilePath: ${strings.symbolFileFormatVersion}(ours), $formatVersion(theirs).');
      exit(1);
    }
    final uniqueNamer = UniqueNamer(libraryImports.keys
        .followedBy([strings.defaultSymbolFileImportPrefix]).toSet());
    for (final file in (symbolFile[strings.files] as YamlMap).keys) {
      final existingImports =
          libraryImports.values.where((element) => element.importPath == file);
      if (existingImports.isEmpty) {
        final name =
            uniqueNamer.makeUnique(strings.defaultSymbolFileImportPrefix);
        libraryImports[name] = LibraryImport(name, file as String);
      }
      final libraryImport = libraryImports.values.firstWhere(
        (element) => element.importPath == file,
      );
      loadImportedTypes(
          symbolFile[strings.files][file] as YamlMap, resultMap, libraryImport);
    }
  }
  return resultMap;
}

Map<String, List<String>> typeMapExtractor(Map<dynamic, dynamic>? yamlConfig) {
  // Key - type_name, Value - [lib, cType, dartType].
  final resultMap = <String, List<String>>{};
  final typeMap = yamlConfig;
  if (typeMap != null) {
    for (final typeName in typeMap.keys) {
      final typeConfigItem = typeMap[typeName] as Map;
      resultMap[typeName as String] = [
        typeConfigItem[strings.lib] as String,
        typeConfigItem[strings.cType] as String,
        typeConfigItem[strings.dartType] as String,
      ];
    }
  }
  return resultMap;
}

Map<String, ImportedType> makeImportTypeMapping(
    Map<String, List<String>> rawTypeMappings,
    Map<String, LibraryImport> libraryImportsMap) {
  final typeMappings = <String, ImportedType>{};
  for (final key in rawTypeMappings.keys) {
    final lib = rawTypeMappings[key]![0];
    final cType = rawTypeMappings[key]![1];
    final dartType = rawTypeMappings[key]![2];
    if (strings.predefinedLibraryImports.containsKey(lib)) {
      typeMappings[key] =
          ImportedType(strings.predefinedLibraryImports[lib]!, cType, dartType);
    } else if (libraryImportsMap.containsKey(lib)) {
      typeMappings[key] =
          ImportedType(libraryImportsMap[lib]!, cType, dartType);
    } else {
      throw Exception("Please declare $lib under library-imports.");
    }
  }
  return typeMappings;
}

Type makePointerToType(Type type, int pointerCount) {
  for (var i = 0; i < pointerCount; i++) {
    type = PointerType(type);
  }
  return type;
}

String makePostfixFromRawVarArgType(List<String> rawVarArgType) {
  return rawVarArgType
      .map((e) => e
          .replaceAll('*', 'Ptr')
          .replaceAll(RegExp(r'_t$'), '')
          .replaceAll(' ', '')
          .replaceAll(RegExp('[^A-Za-z0-9_]'), ''))
      .map((e) => e.length > 1 ? '${e[0].toUpperCase()}${e.substring(1)}' : e)
      .join('');
}

Type makeTypeFromRawVarArgType(
    String rawVarArgType, Map<String, LibraryImport> libraryImportsMap) {
  Type baseType;
  var rawBaseType = rawVarArgType.trim();
  // Split the raw type based on pointer usage. E.g -
  // int => [int]
  // char* => [char,*]
  // ffi.Hello ** => [ffi.Hello,**]
  final typeStringRegexp = RegExp(r'([a-zA-Z0-9_\s\.]+)(\**)$');
  if (!typeStringRegexp.hasMatch(rawBaseType)) {
    throw Exception('Cannot parse variadic argument type - $rawVarArgType.');
  }
  final regExpMatch = typeStringRegexp.firstMatch(rawBaseType)!;
  final groups = regExpMatch.groups([1, 2]);
  rawBaseType = groups[0]!;
  // Handle basic supported types.
  if (cxTypeKindToImportedTypes.containsKey(rawBaseType)) {
    baseType = cxTypeKindToImportedTypes[rawBaseType]!;
  } else if (supportedTypedefToImportedType.containsKey(rawBaseType)) {
    baseType = supportedTypedefToImportedType[rawBaseType]!;
  } else if (suportedTypedefToSuportedNativeType.containsKey(rawBaseType)) {
    baseType = NativeType(suportedTypedefToSuportedNativeType[rawBaseType]!);
  } else {
    // Use library import if specified (E.g - ffi.UintPtr or custom.MyStruct)
    final rawVarArgTypeSplit = rawBaseType.split('.');
    if (rawVarArgTypeSplit.length == 1) {
      final typeName = rawVarArgTypeSplit[0].replaceAll(' ', '');
      baseType = SelfImportedType(typeName, typeName);
    } else if (rawVarArgTypeSplit.length == 2) {
      final lib = rawVarArgTypeSplit[0];
      final libraryImport = strings.predefinedLibraryImports[lib] ??
          libraryImportsMap[rawVarArgTypeSplit[0]];
      if (libraryImport == null) {
        throw Exception('Please declare $lib in library-imports.');
      }
      final typeName = rawVarArgTypeSplit[1].replaceAll(' ', '');
      baseType = ImportedType(libraryImport, typeName, typeName);
    } else {
      throw Exception(
          'Invalid type $rawVarArgType : Expected 0 or 1 .(dot) separators.');
    }
  }

  // Handle pointers
  final pointerCount = groups[1]!.length;
  return makePointerToType(baseType, pointerCount);
}

Map<String, List<VarArgFunction>> makeVarArgFunctionsMapping(
    Map<String, List<RawVarArgFunction>> rawVarArgMappings,
    Map<String, LibraryImport> libraryImportsMap) {
  final mappings = <String, List<VarArgFunction>>{};
  for (final key in rawVarArgMappings.keys) {
    final varArgList = <VarArgFunction>[];
    for (final rawVarArg in rawVarArgMappings[key]!) {
      var postfix = rawVarArg.postfix ?? '';
      final types = <Type>[];
      for (final rva in rawVarArg.rawTypeStrings) {
        types.add(makeTypeFromRawVarArgType(rva, libraryImportsMap));
      }
      if (postfix.isEmpty) {
        if (rawVarArgMappings[key]!.length == 1) {
          postfix = '';
        } else {
          postfix = makePostfixFromRawVarArgType(rawVarArg.rawTypeStrings);
        }
      }
      // Extract postfix from config and/or deduce from var names.
      varArgList.add(VarArgFunction(postfix, types));
    }
    mappings[key] = varArgList;
  }
  return mappings;
}

final _quoteMatcher = RegExp(r'''^["'](.*)["']$''', dotAll: true);
final _cmdlineArgMatcher = RegExp(r'''['"](\\"|[^"])*?['"]|[^ ]+''');
List<String> compilerOptsToList(String compilerOpts) {
  final list = <String>[];
  _cmdlineArgMatcher.allMatches(compilerOpts).forEach((element) {
    var match = element.group(0);
    if (match != null) {
      if (quiver.matchesFull(_quoteMatcher, match)) {
        match = _quoteMatcher.allMatches(match).first.group(1)!;
      }
      list.add(match);
    }
  });

  return list;
}

List<String> compilerOptsExtractor(List<String> value) {
  final list = <String>[];
  for (final el in (value)) {
    list.addAll(compilerOptsToList(el));
  }
  return list;
}

Headers headersExtractor(
    Map<dynamic, List<String>> yamlConfig, String? configFilename) {
  final entryPoints = <String>[];
  final includeGlobs = <quiver.Glob>[];
  for (final key in yamlConfig.keys) {
    if (key == strings.entryPoints) {
      for (final h in (yamlConfig[key]!)) {
        final headerGlob = _normalizePath(h, configFilename);
        // Add file directly to header if it's not a Glob but a File.
        if (File(headerGlob).existsSync()) {
          final osSpecificPath = headerGlob;
          entryPoints.add(osSpecificPath);
          _logger.fine('Adding header/file: $headerGlob');
        } else {
          final glob = Glob(headerGlob);
          for (final file in glob.listFileSystemSync(const LocalFileSystem(),
              followLinks: true)) {
            final fixedPath = file.path;
            entryPoints.add(fixedPath);
            _logger.fine('Adding header/file: $fixedPath');
          }
        }
      }
    }
    if (key == strings.includeDirectives) {
      for (final h in yamlConfig[key]!) {
        final headerGlob = h;
        final fixedGlob = _normalizePath(headerGlob, configFilename);
        includeGlobs.add(quiver.Glob(fixedGlob));
      }
    }
  }
  return Headers(
    entryPoints: entryPoints,
    includeFilter: GlobHeaderFilter(
      includeGlobs: includeGlobs,
    ),
  );
}

/// Returns location of dynamic library by searching default locations. Logs
/// error and throws an Exception if not found.
String findDylibAtDefaultLocations() {
  String? k;
  if (Platform.isLinux) {
    for (final l in strings.linuxDylibLocations) {
      k = findLibclangDylib(l);
      if (k != null) return k;
    }
    Process.runSync('ldconfig', ['-p']);
    final ldConfigResult = Process.runSync('ldconfig', ['-p']);
    if (ldConfigResult.exitCode == 0) {
      final lines = (ldConfigResult.stdout as String).split('\n');
      final paths = [
        for (final line in lines)
          if (line.contains('libclang')) line.split(' => ')[1],
      ];
      for (final location in paths) {
        if (File(location).existsSync()) {
          return location;
        }
      }
    }
  } else if (Platform.isWindows) {
    final dylibLocations = strings.windowsDylibLocations.toList();
    final userHome = Platform.environment['USERPROFILE'];
    if (userHome != null) {
      dylibLocations
          .add(p.join(userHome, 'scoop', 'apps', 'llvm', 'current', 'bin'));
    }
    for (final l in dylibLocations) {
      k = findLibclangDylib(l);
      if (k != null) return k;
    }
  } else if (Platform.isMacOS) {
    for (final l in strings.macOsDylibLocations) {
      k = findLibclangDylib(l);
      if (k != null) return k;
    }
    final findLibraryResult =
        Process.runSync('xcodebuild', ['-find-library', 'libclang.dylib']);
    if (findLibraryResult.exitCode == 0) {
      final location = (findLibraryResult.stdout as String).split('\n').first;
      if (File(location).existsSync()) {
        return location;
      }
    }
    final xcodePathResult = Process.runSync('xcode-select', ['-print-path']);
    if (xcodePathResult.exitCode == 0) {
      final xcodePath = (xcodePathResult.stdout as String).split('\n').first;
      final location =
          p.join(xcodePath, strings.xcodeDylibLocation, strings.dylibFileName);
      if (File(location).existsSync()) {
        return location;
      }
    }
  } else {
    throw Exception('Unsupported Platform.');
  }

  _logger.severe("Couldn't find dynamic library in default locations.");
  _logger.severe(
      "Please supply one or more path/to/llvm in ffigen's config under the key '${strings.llvmPath}'.");
  throw Exception("Couldn't find dynamic library in default locations.");
}

String? findLibclangDylib(String parentFolder) {
  final location = p.join(parentFolder, strings.dylibFileName);
  if (File(location).existsSync()) {
    return location;
  } else {
    return null;
  }
}

String llvmPathExtractor(List<String> value) {
  // Extract libclang's dylib from user specified paths.
  for (final path in value) {
    final dylibPath =
        findLibclangDylib(p.join(path, strings.dynamicLibParentName));
    if (dylibPath != null) {
      _logger.fine('Found dynamic library at: $dylibPath');
      return dylibPath;
    }
    // Check if user has specified complete path to dylib.
    final completeDylibPath = path;
    if (p.extension(completeDylibPath).isNotEmpty &&
        File(completeDylibPath).existsSync()) {
      _logger.info(
          'Using complete dylib path: $completeDylibPath from llvm-path.');
      return completeDylibPath;
    }
  }
  _logger.fine(
      "Couldn't find dynamic library under paths specified by ${strings.llvmPath}.");
  // Extract path from default locations.
  try {
    final res = findDylibAtDefaultLocations();
    return res;
  } catch (e) {
    _logger.severe(
        "Couldn't find ${p.join(strings.dynamicLibParentName, strings.dylibFileName)} in specified locations.");
    exit(1);
  }
}

OutputConfig outputExtractor(
    dynamic value, String? configFilename, PackageConfig? packageConfig) {
  if (value is String) {
    return OutputConfig(_normalizePath(value, configFilename), null);
  }
  value = value as Map;
  return OutputConfig(
    _normalizePath((value)[strings.bindings] as String, configFilename),
    value.containsKey(strings.symbolFile)
        ? symbolFileOutputExtractor(
            value[strings.symbolFile], configFilename, packageConfig)
        : null,
  );
}

SymbolFile symbolFileOutputExtractor(
    dynamic value, String? configFilename, PackageConfig? packageConfig) {
  value = value as Map;
  var output = value[strings.output] as String;
  if (Uri.parse(output).scheme != "package") {
    _logger.warning(
        'Consider using a Package Uri for ${strings.symbolFile} -> ${strings.output}: $output so that external packages can use it.');
    output = _normalizePath(output, configFilename);
  } else {
    output = packageConfig!.resolve(Uri.parse(output))!.toFilePath();
  }
  final importPath = value[strings.importPath] as String;
  if (Uri.parse(importPath).scheme != "package") {
    _logger.warning(
        'Consider using a Package Uri for ${strings.symbolFile} -> ${strings.importPath}: $importPath so that external packages can use it.');
  }
  return SymbolFile(importPath, output);
}

/// Returns true if [str] is not a full name.
///
/// E.g `abc` is a full name, `abc.*` is not.
bool isFullDeclarationName(String str) =>
    quiver.matchesFull(RegExp('[a-zA-Z_0-9]*'), str);

Includer extractIncluderFromYaml(Map<dynamic, dynamic> yamlMap) {
  final includeMatchers = <RegExp>[],
      includeFull = <String>{},
      excludeMatchers = <RegExp>[],
      excludeFull = <String>{};

  final include = yamlMap[strings.include] as List<String>?;
  if (include != null) {
    if (include.isEmpty) {
      return Includer.excludeByDefault();
    }
    for (final str in include) {
      if (isFullDeclarationName(str)) {
        includeFull.add(str);
      } else {
        includeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  final exclude = yamlMap[strings.exclude] as List<String>?;
  if (exclude != null) {
    for (final str in exclude) {
      if (isFullDeclarationName(str)) {
        excludeFull.add(str);
      } else {
        excludeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  return Includer(
    includeMatchers: includeMatchers,
    includeFull: includeFull,
    excludeMatchers: excludeMatchers,
    excludeFull: excludeFull,
  );
}

Map<String, List<RawVarArgFunction>> varArgFunctionConfigExtractor(
    Map<dynamic, dynamic> yamlMap) {
  final result = <String, List<RawVarArgFunction>>{};
  final configMap = yamlMap;
  for (final key in configMap.keys) {
    final List<RawVarArgFunction> vafuncs = [];
    for (final rawVaFunc in (configMap[key] as List)) {
      if (rawVaFunc is List) {
        vafuncs.add(RawVarArgFunction(null, rawVaFunc.cast()));
      } else if (rawVaFunc is Map) {
        vafuncs.add(RawVarArgFunction(rawVaFunc[strings.postfix] as String?,
            (rawVaFunc[strings.types] as List).cast()));
      } else {
        throw Exception("Unexpected type in variadic-argument config.");
      }
    }
    result[key as String] = vafuncs;
  }

  return result;
}

Declaration declarationConfigExtractor(Map<dynamic, dynamic> yamlMap) {
  final renamePatterns = <RegExpRenamer>[];
  final renameFull = <String, String>{};
  final memberRenamePatterns = <RegExpMemberRenamer>[];
  final memberRenamerFull = <String, Renamer>{};

  final includer = extractIncluderFromYaml(yamlMap);

  final symbolIncluder = yamlMap[strings.symbolAddress] as Includer?;

  final rename = yamlMap[strings.rename] as Map<dynamic, String>?;

  if (rename != null) {
    for (final key in rename.keys) {
      final str = key.toString();
      if (isFullDeclarationName(str)) {
        renameFull[str] = rename[str]!;
      } else {
        renamePatterns
            .add(RegExpRenamer(RegExp(str, dotAll: true), rename[str]!));
      }
    }
  }

  final memberRename =
      yamlMap[strings.memberRename] as Map<dynamic, Map<dynamic, String>>?;

  if (memberRename != null) {
    for (final key in memberRename.keys) {
      final decl = key.toString();
      final renamePatterns = <RegExpRenamer>[];
      final renameFull = <String, String>{};

      final memberRenameMap = memberRename[decl]!;
      for (final member in memberRenameMap.keys) {
        final memberStr = member.toString();
        if (isFullDeclarationName(memberStr)) {
          renameFull[memberStr] = memberRenameMap[member]!;
        } else {
          renamePatterns.add(RegExpRenamer(
              RegExp(memberStr, dotAll: true), memberRenameMap[member]!));
        }
      }
      if (isFullDeclarationName(decl)) {
        memberRenamerFull[decl] = Renamer(
          renameFull: renameFull,
          renamePatterns: renamePatterns,
        );
      } else {
        memberRenamePatterns.add(
          RegExpMemberRenamer(
            RegExp(decl, dotAll: true),
            Renamer(
              renameFull: renameFull,
              renamePatterns: renamePatterns,
            ),
          ),
        );
      }
    }
  }

  return Declaration(
    includer: includer,
    renamer: Renamer(
      renameFull: renameFull,
      renamePatterns: renamePatterns,
    ),
    memberRenamer: MemberRenamer(
      memberRenameFull: memberRenamerFull,
      memberRenamePattern: memberRenamePatterns,
    ),
    symbolAddressIncluder: symbolIncluder,
  );
}

StructPackingOverride structPackingOverrideExtractor(
    Map<dynamic, dynamic> value) {
  final matcherMap = <RegExp, int?>{};
  for (final key in value.keys) {
    matcherMap[RegExp(key as String, dotAll: true)] =
        strings.packingValuesMap[value[key]];
  }
  return StructPackingOverride(matcherMap: matcherMap);
}

FfiNativeConfig ffiNativeExtractor(dynamic yamlConfig) {
  final yamlMap = yamlConfig as Map?;
  return FfiNativeConfig(
    enabled: true,
    assetId: yamlMap?[strings.ffiNativeAsset] as String?,
  );
}
