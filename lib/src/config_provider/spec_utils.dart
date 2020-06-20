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
import 'filter.dart';

var _logger = Logger('config_provider/utils');

bool booleanExtractor(dynamic value) => value as bool;

bool booleanValidator(String name, dynamic value) {
  if (value is! bool) {
    _logger.severe('Expected value of key=$name to be a bool');
    return false;
  } else {
    return true;
  }
}

Map<int, SupportedNativeType> sizemapExtractor(dynamic yamlConfig) {
  var resultMap = <int, SupportedNativeType>{};
  var sizemap = yamlConfig as YamlMap;
  if (sizemap != null) {
    for (var typeName in strings.sizemap_native_mapping.keys) {
      if (sizemap.containsKey(typeName)) {
        var cxTypeInt = strings.sizemap_native_mapping[typeName];
        var byteSize = sizemap[typeName] as int;
        resultMap[cxTypeInt] = nativeSupportedType(byteSize,
            signed: typeName.contains('unsigned') ? false : true);
      }
    }
  }
  return resultMap;
}

bool sizemapValidator(String name, dynamic yamlConfig) {
  if (yamlConfig is! YamlMap) {
    _logger.severe('Expected value of key=$name to be a Map');
    return false;
  }
  for (var key in (yamlConfig as YamlMap).keys) {
    if (!strings.sizemap_native_mapping.containsKey(key)) {
      _logger.warning('Unknown subkey in $name: $key');
    }
  }

  return true;
}

List<String> compilerOptsExtractor(dynamic value) =>
    (value as String)?.split(' ');

bool compilerOptsValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe(
        'Warning: Expected value of key=$name to be a string');
    return false;
  } else {
    return true;
  }
}

HeaderFilter headerFilterExtractor(dynamic yamlConfig) {
  var includedInclusionHeaders = <String>{};
  var excludedInclusionHeaders = <String>{};

  var headerFilter = yamlConfig as YamlMap;
  if (headerFilter != null) {
    // Add include/excluded header-filter from Yaml.
    var include = headerFilter[strings.include] as YamlList;
    include?.cast<String>()?.forEach(includedInclusionHeaders.add);

    var exclude = headerFilter[strings.exclude] as YamlList;
    exclude?.cast<String>()?.forEach(excludedInclusionHeaders.add);
  }

  return HeaderFilter(
    includedInclusionHeaders: includedInclusionHeaders,
    excludedInclusionHeaders: excludedInclusionHeaders,
  );
}

bool headerFilterValidator(String name, dynamic value) {
  if (value is! YamlMap) {
    _logger.severe('Expected value of key=$name to be a Map');
    return false;
  } else {
    return true;
  }
}

List<String> headersExtractor(dynamic yamlConfig) {
  var headers = <String>[];
  for (var h in (yamlConfig as YamlList)) {
    var headerGlob = h as String;
    // add file directly to header if it's not a Glob but a File.
    if (File(headerGlob).existsSync()) {
      if (hasValidExtension(headerGlob)) {
        headers.add(headerGlob);
        _logger.fine('Found header/file: $headerGlob');
      } else {
        _logger.warning(
            'Ignoring file: $headerGlob, not a valid extension (only ".c" or ".h" allowed)');
      }
    } else {
      var glob = Glob(headerGlob);
      for (var file in glob.listSync(followLinks: true)) {
        if (hasValidExtension(file.path)) {
          headers.add(file.path);
          _logger.fine('Found header/file: ${file.path}');
        }
      }
    }
  }
  return headers;
}

bool hasValidExtension(String filePath) {
  var ext = p.extension(filePath);
  // TODO check remove .c files later maybe?
  return ext == '.h' || ext == '.c';
}

bool headersValidator(String name, dynamic value) {
  if (value is! YamlList) {
    _logger.severe(
        'Expected value of key=${strings.headers} to be a List of Strings');
    return false;
  } else {
    return true;
  }
}

String libclangDylibExtractor(dynamic value) => getDylibPath(value as String);

bool libclangDylibValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe(
        'Expected value of key=$name to be a string');
    return false;
  } else {
    var dylibPath = getDylibPath(value as String);
    if (!File(dylibPath).existsSync()) {
      _logger.severe(
          'Dynamic library: $dylibPath does not exist or is corrupt, input folder: $value');
      return false;
    } else {
      return true;
    }
  }
}

String getDylibPath(String value) {
  String dylibPath;
  if (Platform.isMacOS) {
    dylibPath = p.join(value, strings.libclang_dylib_macos);
  } else if (Platform.isWindows) {
    // Fix path for windows if '/' is used as seperator instead of '\'
    // because our examples input path like this.
    var newValue = value.replaceAll('/', r'\');
    dylibPath = p.join(newValue, strings.libclang_dylib_windows);
  } else {
    dylibPath = p.join(value, strings.libclang_dylib_linux);
  }
  return dylibPath;
}

String outputExtractor(dynamic value) => value as String;

bool outputValidator(String name, dynamic value) {
  if (value is String) {
    return true;
  } else {
    _logger.severe('Expected value of key=${strings.output} to be a String');
    return false;
  }
}

Filter filterExtractor(dynamic yamlMap) {
  List<String> includeMatchers, includeFull, excludeMatchers, excludeFull;

  var include = yamlMap[strings.include] as YamlMap;
  if (include != null) {
    includeMatchers = (include[strings.matches] as YamlList)?.cast<String>();
    includeFull = (include[strings.names] as YamlList)?.cast<String>();
  }

  var exclude = yamlMap[strings.exclude] as YamlMap;
  if (exclude != null) {
    excludeMatchers = (include[strings.matches] as YamlList)?.cast<String>();
    excludeFull = (include[strings.names] as YamlList)?.cast<String>();
  }

  return Filter(
    includeMatchers: includeMatchers,
    includeFull: includeFull,
    excludeMatchers: excludeMatchers,
    excludeFull: excludeFull,
  );
}

bool filterValidator(String name, dynamic value) {
  var _result = true;
  if (value is YamlMap) {
    for (var key in value.keys) {
      if (key == strings.include || key == strings.exclude) {
        if (value[key] is! YamlMap) {
          _logger.severe('Expected $name->$key to be a Map');
        }
        for (var subkey in value[key].keys) {
          if (subkey == strings.matches || subkey == strings.names) {
            if (value[key][subkey] is! YamlList) {
              _logger.severe('Expected $name->$key->$subkey to be a List');
              _result = false;
            }
          } else {
            _logger.severe('Unknown key found in $name->$key: $subkey');
          }
        }
      } else {
        _logger.severe('Unknown key found $name: $key');
        _result = false;
      }
    }
  } else {
    _logger.severe('Expected value $name to be a Map');
    _result = false;
  }
  return _result;
}

SupportedNativeType nativeSupportedType(dynamic scalar, {bool signed = true}) {
  var value = scalar as int;
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
