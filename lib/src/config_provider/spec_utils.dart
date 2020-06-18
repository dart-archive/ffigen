import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/clang_bindings/clang_constants.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;
import './config.dart';
import 'filter.dart';

var _logger = Logger('config_provider/utils');

dynamic booleanExtractor(dynamic value) => value as bool;

bool booleanValidator(String name, dynamic value) {
  if (value is! bool) {
    _logger.severe('Expected value of key=${name} to be a bool');
    return false;
  } else {
    return true;
  }
}

dynamic sizemapExtractor(dynamic value) {
  var resultMap = <int, SupportedNativeType>{};
  var sizemap = value as YamlMap;
  if (sizemap != null) {
    if (sizemap.containsKey(strings.SChar)) {
      resultMap[CXTypeKind.CXType_SChar] =
          nativeSupportedType(sizemap[strings.SChar]);
    }
    if (sizemap.containsKey(strings.UChar)) {
      resultMap[CXTypeKind.CXType_UChar] =
          nativeSupportedType(sizemap[strings.UChar], signed: false);
    }
    if (sizemap.containsKey(strings.Short)) {
      resultMap[CXTypeKind.CXType_Short] =
          nativeSupportedType(sizemap[strings.Short]);
    }
    if (sizemap.containsKey(strings.UShort)) {
      resultMap[CXTypeKind.CXType_UShort] =
          nativeSupportedType(sizemap[strings.UShort], signed: false);
    }
    if (sizemap.containsKey(strings.Int)) {
      resultMap[CXTypeKind.CXType_Int] =
          nativeSupportedType(sizemap[strings.Int]);
    }
    if (sizemap.containsKey(strings.UInt)) {
      resultMap[CXTypeKind.CXType_UInt] =
          nativeSupportedType(sizemap[strings.UInt], signed: false);
    }
    if (sizemap.containsKey(strings.Long)) {
      resultMap[CXTypeKind.CXType_Long] =
          nativeSupportedType(sizemap[strings.Long]);
    }
    if (sizemap.containsKey(strings.ULong)) {
      resultMap[CXTypeKind.CXType_ULong] =
          nativeSupportedType(sizemap[strings.ULong], signed: false);
    }
    if (sizemap.containsKey(strings.LongLong)) {
      resultMap[CXTypeKind.CXType_LongLong] =
          nativeSupportedType(sizemap[strings.LongLong]);
    }
    if (sizemap.containsKey(strings.ULongLong)) {
      resultMap[CXTypeKind.CXType_ULongLong] =
          nativeSupportedType(sizemap[strings.ULongLong], signed: false);
    }
    if (sizemap.containsKey(strings.Enum)) {
      resultMap[CXTypeKind.CXType_Enum] = nativeSupportedType(
          sizemap[strings.Enum],
          signed: true); // enums are signed ints
    }
  }
  return resultMap;
}

bool sizemapValidator(String name, dynamic value) {
  if (value is! YamlMap) {
    _logger.severe('Expected value of key=$name to be a Map');
    return false;
  }
  for (var key in (value as YamlMap).keys) {
    if (!strings.sizemap_expected_values.contains(key)) {
      _logger.warning('Unknown subkey in $name: $key');
    }
  }

  return true;
}

dynamic compilerOptsExtractor(dynamic value) => (value as String)?.split(' ');

bool compilerOptsValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe(
        'Warning: Expected value of key=${strings.compilerOpts} to be a string');
    return false;
  } else {
    return true;
  }
}

dynamic headerFilterExtractor(dynamic value) {
  var includedInclusionHeaders = <String>{};
  var excludedInclusionHeaders = <String>{};

  var headerFilter = value as YamlMap;
  if (headerFilter != null) {
    var include = headerFilter[strings.include] as YamlList;
    // Add included header-filter from Yaml
    if (include != null) {
      for (var header in include) {
        includedInclusionHeaders.add(header as String);
      }
    }
    var exclude = headerFilter[strings.exclude] as YamlList;
    // Add excluded header-filter from Yaml
    if (exclude != null) {
      for (var header in exclude) {
        excludedInclusionHeaders.add(header as String);
      }
    }
  }

  return HeaderFilter(
    includedInclusionHeaders: includedInclusionHeaders,
    excludedInclusionHeaders: excludedInclusionHeaders,
  );
}

bool headerFilterValidator(String name, dynamic value) {
  if (value is! YamlMap) {
    _logger.severe('Expected value of key=${strings.headerFilter} to be a Map');
    return false;
  } else {
    return true;
  }
}

dynamic headersExtractor(dynamic value) {
  var headers = <String>[];
  for (var h in (value as YamlList)) {
    var headerGlob = h as String;
    // add file directly to header if it's not a Glob but a File
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

dynamic libclangDylibExtractor(dynamic value) => getDylibPath(value as String);

bool libclangDylibValidator(String name, dynamic value) {
  if (value is! String) {
    _logger.severe(
        'Expected value of key=${strings.libclang_dylib_folder} to be a string');
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
    // because our examples input path like this
    var newValue = value.replaceAll('/', r'\');
    dylibPath = p.join(newValue, strings.libclang_dylib_windows);
  } else {
    dylibPath = p.join(value, strings.libclang_dylib_linux);
  }
  return dylibPath;
}

dynamic outputExtractor(dynamic value) => value as String;

bool outputValidator(String name, dynamic value) {
  if (value is String) {
    return true;
  } else {
    _logger.severe('Expected value of key=${strings.output} to be a String');
    return false;
  }
}

dynamic filterExtractor(dynamic map) {
  List<String> includeMatchers, includeFull, excludeMatchers, excludeFull;

  var include = map[strings.include] as YamlMap;
  if (include != null) {
    includeMatchers = (include[strings.matches] as YamlList)
        ?.map((dynamic e) => e as String)
        ?.toList();
    includeFull = (include[strings.names] as YamlList)
        ?.map((dynamic e) => e as String)
        ?.toList();
  }

  var exclude = map[strings.exclude] as YamlMap;

  if (exclude != null) {
    excludeMatchers = (map[strings.exclude][strings.matches] as YamlList)
        ?.map((dynamic e) => e as String)
        ?.toList();
    excludeFull = (map[strings.exclude][strings.names] as YamlList)
        ?.map((dynamic e) => e as String)
        ?.toList();
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
          _logger.severe('Expected $name>$key to be a Map');
        }
        for (var subkey in value[key].keys) {
          if (subkey == strings.matches || subkey == strings.names) {
            if (value[key][subkey] is! YamlList) {
              _logger.severe('Expected $name>$key>$subkey to be a List');
              _result = false;
            }
          } else {
            _logger.severe('Unknown key found in $name>$key: $subkey');
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
