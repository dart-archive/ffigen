// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:quiver/pattern.dart' as quiver;

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
        "Expected value of key '${keys.join(' -> ')}' to be of type '${T}'.");
    return false;
  }
  return true;
}

bool booleanExtractor(dynamic value) => value as bool;

bool booleanValidator(String name, dynamic value) =>
    checkType<bool>([name], value);

Map<int, SupportedNativeType> sizemapExtractor(dynamic yamlConfig) {
  final resultMap = <int, SupportedNativeType>{};
  final sizemap = yamlConfig as YamlMap;
  if (sizemap != null) {
    for (final typeName in strings.sizemap_native_mapping.keys) {
      if (sizemap.containsKey(typeName)) {
        final cxTypeInt = strings.sizemap_native_mapping[typeName];
        final byteSize = sizemap[typeName] as int;
        resultMap[cxTypeInt] = nativeSupportedType(byteSize,
            signed: typeName.contains('unsigned') ? false : true);
      }
    }
  }
  return resultMap;
}

bool sizemapValidator(String name, dynamic yamlConfig) {
  if (!checkType<YamlMap>([name], yamlConfig)) {
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
  final typedefmap = yamlConfig as YamlMap;
  if (typedefmap != null) {
    for (final typeName in typedefmap.keys) {
      if (typedefmap[typeName] is String &&
          strings.supportedNativeType_mappings
              .containsKey(typedefmap[typeName])) {
        // Map this typename to specified supportedNativeType.
        resultMap[typeName as String] =
            strings.supportedNativeType_mappings[typedefmap[typeName]];
      }
    }
  }
  return resultMap;
}

bool typedefmapValidator(String name, dynamic yamlConfig) {
  if (!checkType<YamlMap>([name], yamlConfig)) {
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

List<String> compilerOptsExtractor(dynamic value) =>
    (value as String)?.split(' ');

bool compilerOptsValidator(String name, dynamic value) =>
    checkType<String>([name], value);

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
          for (final file in glob.listSync(followLinks: true)) {
            final fixedPath = _replaceSeparators(file.path);
            entryPoints.add(fixedPath);
            _logger.fine('Adding header/file: ${fixedPath}');
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

bool headersValidator(String name, dynamic value) {
  if (!checkType<YamlMap>([name], value)) {
    return false;
  }
  if (!(value as YamlMap).containsKey(strings.entryPoints)) {
    _logger.severe("Expected '$name -> ${strings.entryPoints}' to be a Map.");
    return false;
  } else {
    for (final key in (value as YamlMap).keys) {
      if (key == strings.entryPoints || key == strings.includeDirectives) {
        if (!checkType<YamlList>([name, key as String], value[key])) {
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

bool libclangDylibValidator(String name, dynamic value) {
  if (!checkType<String>([name], value)) {
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

String outputExtractor(dynamic value) => _replaceSeparators(value as String);

bool outputValidator(String name, dynamic value) =>
    checkType<String>([name], value);

/// Returns true if [str] is not a full name.
///
/// E.g `abc` is a full name, `abc.*` is not.
bool isFullDeclarationName(String str) =>
    quiver.matchesFull(RegExp('[a-zA-Z_0-9]*'), str);

Declaration declarationConfigExtractor(dynamic yamlMap) {
  final includeMatchers = <RegExp>[],
      includeFull = <String>{},
      excludeMatchers = <RegExp>[],
      excludeFull = <String>{};
  final renamePatterns = <RegExpRenamer>[];
  final renameFull = <String, String>{};
  final memberRenamePatterns = <RegExpMemberRenamer>[];
  final memberRenamerFull = <String, Renamer>{};

  final include = (yamlMap[strings.include] as YamlList)?.cast<String>();
  if (include != null) {
    for (final str in include) {
      if (isFullDeclarationName(str)) {
        includeFull.add(str);
      } else {
        includeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  final exclude = (yamlMap[strings.exclude] as YamlList)?.cast<String>();
  if (exclude != null) {
    for (final str in exclude) {
      if (isFullDeclarationName(str)) {
        excludeFull.add(str);
      } else {
        excludeMatchers.add(RegExp(str, dotAll: true));
      }
    }
  }

  final rename = (yamlMap[strings.rename] as YamlMap)?.cast<String, String>();

  if (rename != null) {
    for (final str in rename.keys) {
      if (isFullDeclarationName(str)) {
        renameFull[str] = rename[str];
      } else {
        renamePatterns
            .add(RegExpRenamer(RegExp(str, dotAll: true), rename[str]));
      }
    }
  }

  final memberRename =
      (yamlMap[strings.memberRename] as YamlMap)?.cast<String, YamlMap>();

  if (memberRename != null) {
    for (final decl in memberRename.keys) {
      final renamePatterns = <RegExpRenamer>[];
      final renameFull = <String, String>{};

      final memberRenameMap = memberRename[decl].cast<String, String>();
      for (final member in memberRenameMap.keys) {
        if (isFullDeclarationName(member)) {
          renameFull[member] = memberRenameMap[member];
        } else {
          renamePatterns.add(RegExpRenamer(
              RegExp(member, dotAll: true), memberRenameMap[member]));
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
    includer: Includer(
      includeMatchers: includeMatchers,
      includeFull: includeFull,
      excludeMatchers: excludeMatchers,
      excludeFull: excludeFull,
    ),
    renamer: Renamer(
      renameFull: renameFull,
      renamePatterns: renamePatterns,
    ),
    memberRenamer: MemberRenamer(
      memberRenameFull: memberRenamerFull,
      memberRenamePattern: memberRenamePatterns,
    ),
  );
}

bool declarationConfigValidator(String name, dynamic value) {
  var _result = true;
  if (value is YamlMap) {
    for (final key in value.keys) {
      if (key == strings.include || key == strings.exclude) {
        if (!checkType<YamlList>([name, key as String], value[key])) {
          _result = false;
        }
      } else if (key == strings.rename) {
        if (!checkType<YamlMap>([name, key as String], value[key])) {
          _result = false;
        } else {
          for (final subkey in value[key].keys) {
            if (!checkType<String>(
                [name, key as String, subkey as String], value[key][subkey])) {
              _result = false;
            }
          }
        }
      } else if (key == strings.memberRename) {
        if (!checkType<YamlMap>([name, key as String], value[key])) {
          _result = false;
        } else {
          for (final declNameKey in value[key].keys) {
            if (!checkType<YamlMap>(
                [name, key as String, declNameKey as String],
                value[key][declNameKey])) {
              _result = false;
            } else {
              for (final memberNameKey in value[key][declNameKey].keys) {
                if (!checkType<String>([
                  name,
                  key as String,
                  declNameKey as String,
                  memberNameKey as String,
                ], value[key][declNameKey][memberNameKey])) {
                  _result = false;
                }
              }
            }
          }
        }
      } else {
        _logger.severe("Unknown key '$key' in '$name'.");
        _result = false;
      }
    }
  } else {
    _logger.severe("Expected value '$name' to be a Map.");
    _result = false;
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

bool nonEmptyStringValidator(String name, dynamic value) {
  if (value is String && value.isNotEmpty) {
    return true;
  } else {
    _logger.severe("Expected value of key '$name' to be a non-empty String.");
    return false;
  }
}

bool dartClassNameValidator(String name, dynamic value) {
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

bool commentValidator(String name, dynamic value) {
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
