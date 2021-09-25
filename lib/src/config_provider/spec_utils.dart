// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
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

/// Checks if type of value is [T], logs an error if it's not.
///
/// [key] is printed as `'item1 -> item2 => item3'` in log message.
bool checkType<T>(List<String> keys, dynamic value) {
  if (value is! T) {
    _logger.severe(
        "Expected value of key '${keys.join(' -> ')}' to be of type '$T'.");
    return false;
  }
  return true;
}

/// Checks if there are nested [key] in [map].
bool checkKeyInYaml(List<String> key, YamlMap map) {
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
dynamic getKeyValueFromYaml(List<String> key, YamlMap map) {
  if (checkKeyInYaml(key, map)) {
    dynamic last = map;
    for (final k in key) {
      last = last[k];
    }
    return last;
  }

  return null;
}

bool booleanExtractor(dynamic value) => value as bool;

bool booleanValidator(List<String> name, dynamic value) =>
    checkType<bool>(name, value);

Map<int, SupportedNativeType> sizemapExtractor(dynamic yamlConfig) {
  final resultMap = <int, SupportedNativeType>{};
  final sizemap = yamlConfig as YamlMap?;
  if (sizemap != null) {
    for (final typeName in strings.sizemap_native_mapping.keys) {
      if (sizemap.containsKey(typeName)) {
        final cxTypeInt = strings.sizemap_native_mapping[typeName] as int;
        final byteSize = sizemap[typeName] as int;
        resultMap[cxTypeInt] = nativeSupportedType(byteSize,
            signed: typeName.contains('unsigned') ? false : true);
      }
    }
  }
  return resultMap;
}

bool sizemapValidator(List<String> name, dynamic yamlConfig) {
  if (!checkType<YamlMap>(name, yamlConfig)) {
    return false;
  }
  for (final key in (yamlConfig as YamlMap).keys) {
    if (!strings.sizemap_native_mapping.containsKey(key)) {
      _logger.warning("Unknown subkey '$key' in '$name'.");
    }
  }

  return true;
}

Map<String, SupportedNativeType> typedefmapExtractor(dynamic yamlConfig) {
  final resultMap = <String, SupportedNativeType>{};
  final typedefmap = yamlConfig as YamlMap?;
  if (typedefmap != null) {
    for (final typeName in typedefmap.keys) {
      if (typedefmap[typeName] is String &&
          strings.supportedNativeType_mappings
              .containsKey(typedefmap[typeName])) {
        // Map this typename to specified supportedNativeType.
        resultMap[typeName as String] =
            strings.supportedNativeType_mappings[typedefmap[typeName]]!;
      }
    }
  }
  return resultMap;
}

bool typedefmapValidator(List<String> name, dynamic yamlConfig) {
  if (!checkType<YamlMap>(name, yamlConfig)) {
    return false;
  }
  for (final value in (yamlConfig as YamlMap).values) {
    if (value is! String ||
        !strings.supportedNativeType_mappings.containsKey(value)) {
      _logger.severe("Unknown value of subkey '$value' in '$name'.");
    }
  }

  return true;
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

List<String> compilerOptsExtractor(dynamic value) {
  if (value is String) {
    return compilerOptsToList(value);
  }

  final list = <String>[];
  for (final el in (value as YamlList)) {
    if (el is String) {
      list.addAll(compilerOptsToList(el));
    }
  }
  return list;
}

bool compilerOptsValidator(List<String> name, dynamic value) {
  if (value is String || value is YamlList) {
    return true;
  } else {
    _logger.severe('Expected $name to be a String or List of String.');
    return false;
  }
}

CompilerOptsAuto compilerOptsAutoExtractor(dynamic value) {
  return CompilerOptsAuto(
    macIncludeStdLib: getKeyValueFromYaml(
      [strings.macos, strings.includeCStdLib],
      value as YamlMap,
    ) as bool?,
  );
}

bool compilerOptsAutoValidator(List<String> name, dynamic value) {
  var _result = true;

  if (!checkType<YamlMap>(name, value)) {
    return false;
  }

  for (final oskey in (value as YamlMap).keys) {
    if (oskey == strings.macos) {
      if (!checkType<YamlMap>([...name, oskey as String], value[oskey])) {
        return false;
      }

      for (final inckey in (value[oskey] as YamlMap).keys) {
        if (inckey == strings.includeCStdLib) {
          if (!checkType<bool>(
              [...name, oskey, inckey as String], value[oskey][inckey])) {
            _result = false;
          }
        } else {
          _logger.severe("Unknown key '$inckey' in '$name -> $oskey.");
          _result = false;
        }
      }
    } else {
      _logger.severe("Unknown key '$oskey' in '$name'.");
      _result = false;
    }
  }
  return _result;
}

Headers headersExtractor(dynamic yamlConfig) {
  final entryPoints = <String>[];
  final includeGlobs = <quiver.Glob>[];
  for (final key in (yamlConfig as YamlMap).keys) {
    if (key == strings.entryPoints) {
      for (final h in (yamlConfig[key] as YamlList)) {
        final headerGlob = h as String;
        // Add file directly to header if it's not a Glob but a File.
        if (File(headerGlob).existsSync()) {
          final osSpecificPath = _replaceSeparators(headerGlob);
          entryPoints.add(osSpecificPath);
          _logger.fine('Adding header/file: $headerGlob');
        } else {
          final glob = Glob(headerGlob);
          for (final file in glob.listFileSystemSync(const LocalFileSystem(),
              followLinks: true)) {
            final fixedPath = _replaceSeparators(file.path);
            entryPoints.add(fixedPath);
            _logger.fine('Adding header/file: $fixedPath');
          }
        }
      }
    }
    if (key == strings.includeDirectives) {
      for (final h in (yamlConfig[key] as YamlList)) {
        final headerGlob = h as String;
        includeGlobs.add(quiver.Glob(headerGlob));
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

bool headersValidator(List<String> name, dynamic value) {
  if (!checkType<YamlMap>(name, value)) {
    return false;
  }
  if (!(value as YamlMap).containsKey(strings.entryPoints)) {
    _logger.severe("Required '$name -> ${strings.entryPoints}'.");
    return false;
  } else {
    for (final key in value.keys) {
      if (key == strings.entryPoints || key == strings.includeDirectives) {
        if (!checkType<YamlList>([...name, key as String], value[key])) {
          return false;
        }
      } else {
        _logger.severe("Unknown key '$key' in '$name'.");
        return false;
      }
    }
    return true;
  }
}

String libclangDylibExtractor(dynamic value) => getDylibPath(value as String);

bool libclangDylibValidator(List<String> name, dynamic value) {
  if (!checkType<String>(name, value)) {
    return false;
  } else {
    final dylibPath = getDylibPath(value as String);
    if (!File(dylibPath).existsSync()) {
      _logger.severe(
          'Dynamic library: $dylibPath does not exist or is corrupt, input folder: $value.');
      return false;
    } else {
      return true;
    }
  }
}

String getDylibPath(String dylibParentFoler) {
  dylibParentFoler = _replaceSeparators(dylibParentFoler);
  String dylibPath;
  if (Platform.isMacOS) {
    dylibPath = p.join(dylibParentFoler, strings.libclang_dylib_macos);
  } else if (Platform.isWindows) {
    dylibPath = p.join(dylibParentFoler, strings.libclang_dylib_windows);
  } else {
    dylibPath = p.join(dylibParentFoler, strings.libclang_dylib_linux);
  }
  return dylibPath;
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
  } else if (Platform.isWindows) {
    for (final l in strings.windowsDylibLocations) {
      k = findLibclangDylib(l);
      if (k != null) return k;
    }
  } else if (Platform.isMacOS) {
    for (final l in strings.macOsDylibLocations) {
      k = findLibclangDylib(l);
      if (k != null) return k;
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

String llvmPathExtractor(dynamic value) {
  // Extract libclang's dylib from user specified paths.
  for (final path in (value as YamlList)) {
    if (path is! String) continue;
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

bool llvmPathValidator(List<String> name, dynamic value) {
  if (!checkType<YamlList>(name, value)) {
    return false;
  }
  return true;
}

String outputExtractor(dynamic value) => _replaceSeparators(value as String);

bool outputValidator(List<String> name, dynamic value) =>
    checkType<String>(name, value);

/// Returns true if [str] is not a full name.
///
/// E.g `abc` is a full name, `abc.*` is not.
bool isFullDeclarationName(String str) =>
    quiver.matchesFull(RegExp('[a-zA-Z_0-9]*'), str);

Includer _extractIncluderFromYaml(dynamic yamlMap) {
  final includeMatchers = <RegExp>[],
      includeFull = <String>{},
      excludeMatchers = <RegExp>[],
      excludeFull = <String>{};

  final include = (yamlMap[strings.include] as YamlList?)?.cast<String>();
  if (include != null) {
    for (final str in include) {
      if (isFullDeclarationName(str)) {
        includeFull.add(str);
      } else {
        includeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  final exclude = (yamlMap[strings.exclude] as YamlList?)?.cast<String>();
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

Declaration declarationConfigExtractor(dynamic yamlMap) {
  final renamePatterns = <RegExpRenamer>[];
  final renameFull = <String, String>{};
  final memberRenamePatterns = <RegExpMemberRenamer>[];
  final memberRenamerFull = <String, Renamer>{};

  final includer = _extractIncluderFromYaml(yamlMap);

  Includer? symbolIncluder;
  if (yamlMap[strings.symbolAddress] != null) {
    symbolIncluder = _extractIncluderFromYaml(yamlMap[strings.symbolAddress]);
  }

  final rename = (yamlMap[strings.rename] as YamlMap?)?.cast<String, String>();

  if (rename != null) {
    for (final str in rename.keys) {
      if (isFullDeclarationName(str)) {
        renameFull[str] = rename[str]!;
      } else {
        renamePatterns
            .add(RegExpRenamer(RegExp(str, dotAll: true), rename[str]!));
      }
    }
  }

  final memberRename =
      (yamlMap[strings.memberRename] as YamlMap?)?.cast<String, YamlMap>();

  if (memberRename != null) {
    for (final decl in memberRename.keys) {
      final renamePatterns = <RegExpRenamer>[];
      final renameFull = <String, String>{};

      final memberRenameMap = memberRename[decl]!.cast<String, String>();
      for (final member in memberRenameMap.keys) {
        if (isFullDeclarationName(member)) {
          renameFull[member] = memberRenameMap[member]!;
        } else {
          renamePatterns.add(RegExpRenamer(
              RegExp(member, dotAll: true), memberRenameMap[member]!));
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

bool declarationConfigValidator(List<String> name, dynamic value) {
  var _result = true;
  if (value is YamlMap) {
    for (final key in value.keys) {
      if (key == strings.include || key == strings.exclude) {
        if (!checkType<YamlList>([...name, key as String], value[key])) {
          _result = false;
        }
      } else if (key == strings.rename) {
        if (!checkType<YamlMap>([...name, key as String], value[key])) {
          _result = false;
        } else {
          for (final subkey in value[key].keys) {
            if (!checkType<String>(
                [...name, key, subkey as String], value[key][subkey])) {
              _result = false;
            }
          }
        }
      } else if (key == strings.memberRename) {
        if (!checkType<YamlMap>([...name, key as String], value[key])) {
          _result = false;
        } else {
          for (final declNameKey in value[key].keys) {
            if (!checkType<YamlMap>([...name, key, declNameKey as String],
                value[key][declNameKey])) {
              _result = false;
            } else {
              for (final memberNameKey in value[key][declNameKey].keys) {
                if (!checkType<String>([
                  ...name,
                  key,
                  declNameKey,
                  memberNameKey as String,
                ], value[key][declNameKey][memberNameKey])) {
                  _result = false;
                }
              }
            }
          }
        }
      } else if (key == strings.symbolAddress) {
        if (!checkType<YamlMap>([...name, key as String], value[key])) {
          _result = false;
        } else {
          for (final subkey in value[key].keys) {
            if (subkey == strings.include || subkey == strings.exclude) {
              if (!checkType<YamlList>(
                  [...name, key, subkey as String], value[key][subkey])) {
                _result = false;
              }
            } else {
              _logger.severe("Unknown key '$subkey' in '$name -> $key'.");
              _result = false;
            }
          }
        }
      }
    }
  } else {
    _logger.severe("Expected value '$name' to be a Map.");
    _result = false;
  }
  return _result;
}

Includer exposeFunctionTypeExtractor(dynamic value) =>
    _extractIncluderFromYaml(value);

bool exposeFunctionTypeValidator(List<String> name, dynamic value) {
  var _result = true;

  if (!checkType<YamlMap>(name, value)) {
    _result = false;
  } else {
    final mp = value as YamlMap;
    for (final key in mp.keys) {
      if (key == strings.include || key == strings.exclude) {
        if (!checkType<YamlList>([...name, key as String], value[key])) {
          _result = false;
        }
      } else {
        _logger.severe("Unknown subkey '$key' in '$name'.");
        _result = false;
      }
    }
  }

  return _result;
}

Includer leafFunctionExtractor(dynamic value) =>
    _extractIncluderFromYaml(value);

bool leafFunctionValidator(List<String> name, dynamic value) {
  var _result = true;

  if (!checkType<YamlMap>(name, value)) {
    _result = false;
  } else {
    final mp = value as YamlMap;
    for (final key in mp.keys) {
      if (key == strings.include || key == strings.exclude) {
        if (!checkType<YamlList>([...name, key as String], value[key])) {
          _result = false;
        }
      } else {
        _logger.severe("Unknown subkey '$key' in '$name'.");
        _result = false;
      }
    }
  }

  return _result;
}

SupportedNativeType nativeSupportedType(int value, {bool signed = true}) {
  switch (value) {
    case 1:
      return signed ? SupportedNativeType.Int8 : SupportedNativeType.Uint8;
    case 2:
      return signed ? SupportedNativeType.Int16 : SupportedNativeType.Uint16;
    case 4:
      return signed ? SupportedNativeType.Int32 : SupportedNativeType.Uint32;
    case 8:
      return signed ? SupportedNativeType.Int64 : SupportedNativeType.Uint64;
    default:
      throw Exception(
          'Unsupported value given to sizemap, Allowed values for sizes are: 1, 2, 4, 8');
  }
}

String stringExtractor(dynamic value) => value as String;

bool nonEmptyStringValidator(List<String> name, dynamic value) {
  if (value is String && value.isNotEmpty) {
    return true;
  } else {
    _logger.severe("Expected value of key '$name' to be a non-empty String.");
    return false;
  }
}

bool dartClassNameValidator(List<String> name, dynamic value) {
  if (value is String &&
      quiver.matchesFull(RegExp('[a-zA-Z]+[_a-zA-Z0-9]*'), value)) {
    return true;
  } else {
    _logger.severe(
        "Expected value of key '$name' to be a valid public class name.");
    return false;
  }
}

CommentType commentExtractor(dynamic value) {
  if (value is bool) {
    if (value) {
      return CommentType.def();
    } else {
      return CommentType.none();
    }
  }
  final ct = CommentType.def();
  if (value is YamlMap) {
    for (final key in value.keys) {
      if (key == strings.style) {
        if (value[key] == strings.any) {
          ct.style = CommentStyle.any;
        } else if (value[key] == strings.doxygen) {
          ct.style = CommentStyle.doxygen;
        }
      } else if (key == strings.length) {
        if (value[key] == strings.full) {
          ct.length = CommentLength.full;
        } else if (value[key] == strings.brief) {
          ct.length = CommentLength.brief;
        }
      }
    }
  }
  return ct;
}

bool commentValidator(List<String> name, dynamic value) {
  if (value is bool) {
    return true;
  } else if (value is YamlMap) {
    var result = true;
    for (final key in value.keys) {
      if (key == strings.style) {
        if (value[key] is! String ||
            !(value[key] == strings.doxygen || value[key] == strings.any)) {
          _logger.severe(
              "'$name'>'${strings.style}' must be one of the following - {${strings.doxygen}, ${strings.any}}");
          result = false;
        }
      } else if (key == strings.length) {
        if (value[key] is! String ||
            !(value[key] == strings.brief || value[key] == strings.full)) {
          _logger.severe(
              "'$name'>'${strings.length}' must be one of the following - {${strings.brief}, ${strings.full}}");
          result = false;
        }
      } else {
        _logger.severe("Unknown key '$key' in '$name'.");
        result = false;
      }
    }
    return result;
  } else {
    _logger.severe("Expected value of key '$name' to be a bool or a Map.");
    return false;
  }
}

CompoundDependencies dependencyOnlyExtractor(dynamic value) {
  var result = CompoundDependencies.full;
  if (value == strings.opaqueCompoundDependencies) {
    result = CompoundDependencies.opaque;
  }
  return result;
}

bool dependencyOnlyValidator(List<String> name, dynamic value) {
  var result = true;
  if (value is! String ||
      !(value == strings.fullCompoundDependencies ||
          value == strings.opaqueCompoundDependencies)) {
    _logger.severe(
        "'$name' must be one of the following - {${strings.fullCompoundDependencies}, ${strings.opaqueCompoundDependencies}}");
    result = false;
  }
  return result;
}

StructPackingOverride structPackingOverrideExtractor(dynamic value) {
  final matcherMap = <RegExp, int?>{};
  for (final key in value.keys) {
    matcherMap[RegExp(key as String, dotAll: true)] =
        strings.packingValuesMap[value[key]];
  }
  return StructPackingOverride(matcherMap: matcherMap);
}

bool structPackingOverrideValidator(List<String> name, dynamic value) {
  var _result = true;

  if (!checkType<YamlMap>([...name], value)) {
    _result = false;
  } else {
    for (final key in value.keys) {
      if (!(strings.packingValuesMap.keys.contains(value[key]))) {
        _logger.severe(
            "'$name -> $key' must be one of the following - ${strings.packingValuesMap.keys.toList()}");
        _result = false;
      }
    }
  }

  return _result;
}
