// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import './config.dart';
import 'declaration.dart';

var _logger = Logger('config_provider:spec_utils.dart');

bool booleanExtractor(dynamic value) => value as bool;

bool booleanValidator(String name, dynamic value) {
  if (value is! bool) {
    _logger.severe("Expected value of key '$name' to be a bool.");
    return false;
  } else {
    return true;
  }
}

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
  if (yamlConfig is! YamlMap) {
    _logger.severe("Expected value of key '$name' to be a Map.");
    return false;
  }
  for (final key in (yamlConfig as YamlMap).keys) {
    if (!strings.sizemap_native_mapping.containsKey(key)) {
      _logger.warning("Unknown subkey '$key' in '$name'.");
    }
  }

  return true;
}

List<String> compilerOptsExtractor(dynamic value) =>
    (value as String)?.split(' ');

bool compilerOptsValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe("Expected value of key '$name' to be a string.");
    return false;
  } else {
    return true;
  }
}

HeaderFilter headerFilterExtractor(dynamic yamlConfig) {
  final includedInclusionHeaders = <String>{};
  final excludedInclusionHeaders = <String>{};

  final headerFilter = yamlConfig as YamlMap;
  if (headerFilter != null) {
    // Add include/excluded header-filter from Yaml.
    final include = headerFilter[strings.include] as YamlList;
    include?.cast<String>()?.forEach(includedInclusionHeaders.add);

    final exclude = headerFilter[strings.exclude] as YamlList;
    exclude?.cast<String>()?.forEach(excludedInclusionHeaders.add);
  }

  return HeaderFilter(
    includedInclusionHeaders: includedInclusionHeaders,
    excludedInclusionHeaders: excludedInclusionHeaders,
  );
}

bool headerFilterValidator(String name, dynamic value) {
  if (value is! YamlMap) {
    _logger.severe("Expected value of key '$name' to be a Map.");
    return false;
  } else {
    return true;
  }
}

List<String> headersExtractor(dynamic yamlConfig) {
  final headers = <String>[];
  for (final h in (yamlConfig as YamlList)) {
    final headerGlob = h as String;
    // Add file directly to header if it's not a Glob but a File.
    if (File(headerGlob).existsSync()) {
      headers.add(headerGlob);
      _logger.fine('Adding header/file: $headerGlob');
    } else {
      final glob = Glob(headerGlob);
      for (final file in glob.listSync(followLinks: true)) {
        headers.add(file.path);
        _logger.fine('Adding header/file: ${file.path}');
      }
    }
  }
  return headers;
}

bool headersValidator(String name, dynamic value) {
  if (value is! YamlList) {
    _logger.severe(
        "Expected value of key '${strings.headers}' to be a List of String.");
    return false;
  } else {
    return true;
  }
}

String libclangDylibExtractor(dynamic value) => getDylibPath(value as String);

bool libclangDylibValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe("Expected value of key '$name' to be a string.");
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
  String dylibPath;
  if (Platform.isMacOS) {
    dylibPath = p.join(dylibParentFoler, strings.libclang_dylib_macos);
  } else if (Platform.isWindows) {
    // Fix path for windows if '/' is used as seperator instead of '\'
    // because our examples input path like this.
    final newValue = dylibParentFoler.replaceAll('/', r'\');
    dylibPath = p.join(newValue, strings.libclang_dylib_windows);
  } else {
    dylibPath = p.join(dylibParentFoler, strings.libclang_dylib_linux);
  }
  return dylibPath;
}

String outputExtractor(dynamic value) => value as String;

bool outputValidator(String name, dynamic value) {
  if (value is String) {
    return true;
  } else {
    _logger.severe("Expected value of key '$name' to be a String.");
    return false;
  }
}

Declaration declarationConfigExtractor(dynamic yamlMap) {
  List<String> includeMatchers, includeFull, excludeMatchers, excludeFull;
  String prefix;
  Map<String, String> prefixReplacement;

  final include = yamlMap[strings.include] as YamlMap;
  if (include != null) {
    includeMatchers = (include[strings.matches] as YamlList)?.cast<String>();
    includeFull = (include[strings.names] as YamlList)?.cast<String>();
  }

  final exclude = yamlMap[strings.exclude] as YamlMap;
  if (exclude != null) {
    excludeMatchers = (exclude[strings.matches] as YamlList)?.cast<String>();
    excludeFull = (exclude[strings.names] as YamlList)?.cast<String>();
  }

  prefix = yamlMap[strings.prefix] as String;

  prefixReplacement =
      (yamlMap[strings.prefix_replacement] as YamlMap)?.cast<String, String>();

  return Declaration(
    includeMatchers: includeMatchers,
    includeFull: includeFull,
    excludeMatchers: excludeMatchers,
    excludeFull: excludeFull,
    globalPrefix: prefix,
    prefixReplacement: prefixReplacement,
  );
}

bool declarationConfigValidator(String name, dynamic value) {
  var _result = true;
  if (value is YamlMap) {
    for (final key in value.keys) {
      if (key == strings.include || key == strings.exclude) {
        if (value[key] is! YamlMap) {
          _logger.severe("Expected '$name -> $key' to be a Map.");
          _result = false;
        }
        for (final subkey in value[key].keys) {
          if (subkey == strings.matches || subkey == strings.names) {
            if (value[key][subkey] is! YamlList) {
              _logger
                  .severe("Expected '$name -> $key -> $subkey' to be a List.");
              _result = false;
            }
          } else {
            _logger.severe("Unknown key '$subkey' in '$name -> $key'.");
          }
        }
      } else if (key == strings.prefix) {
        if (value[key] is! String) {
          _logger.severe("Expected '$name -> $key' to be a String.");
          _result = false;
        }
      } else if (key == strings.prefix_replacement) {
        if (value[key] is! YamlMap) {
          _logger.severe("Expected '$name -> $key' to be a Map.");
          _result = false;
        } else {
          for (final subkey in value[key].keys) {
            if (value[key][subkey] is! String) {
              _logger.severe(
                  "Expected '$name -> $key -> $subkey' to be a String.");
              _result = false;
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

String commentExtractor(dynamic value) => value as String;

bool commentValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe("Expected value of key '$name' to be a String.");
    return false;
  } else {
    if (strings.commentTypeSet.contains(value as String)) {
      return true;
    } else {
      _logger.severe(
          "Value of key '$name' must be one of the following - ${strings.commentTypeSet}.");
      return false;
    }
  }
}
