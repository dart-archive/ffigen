/// Validates the yaml input by the user,
/// prints useful info for the user
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import '../strings.dart' as strings;

var _logger = Logger('config_provider');

enum CheckerResult {
  error,
  warnings,
  correct,
}

CheckerResult _result = CheckerResult.correct;

/// Validates the given yaml schema and returns [CheckerResult]
///
/// logs warning for unknown config options (if any)
CheckerResult checkYaml(YamlMap map) {
  _result = CheckerResult.correct;

  // TODO: Validate output file
  
  _validateLibclangDylibPath(map);

  // TODO: Validate headers

  _validateCompilerOpts(map);

  // TODO: Validate filters

  _validateSort(map);

  // print unknown attributes
  _warnUnknownConfigKeys(map);

  return _result;
}

void _validateSort(YamlMap map) {
  if (map.containsKey(strings.sort) && map[strings.sort] is! bool) {
    _logger
        .severe('Warning: Expected value of key=${strings.sort} to be a bool');
    _setResult(CheckerResult.error);
  }
}

void _warnUnknownConfigKeys(YamlMap map) {
  var unknownopts = <String>[];
  for (var k in map.keys) {
    var key = k as String;
    if (!strings.mapOfAllOptions.containsKey(key)) {
      unknownopts.add(key);
    }
  }
  if (unknownopts.isNotEmpty) {
    _logger.warning('Warning: Unknown keys found - ' + unknownopts.join(', '));
    _setResult(CheckerResult.warnings);
  }
}

void _validateCompilerOpts(YamlMap map) {
  if (map.containsKey(strings.compilerOpts) &&
      map[strings.compilerOpts] is! String) {
    _logger.severe(
        'Warning: Expected value of key=${strings.compilerOpts} to be a string');
    _setResult(CheckerResult.error);
  }
}

void _validateLibclangDylibPath(YamlMap map) {
  if (map.containsKey(strings.libclang_dylib)) {
    if (map[strings.libclang_dylib] is! String) {
      _logger.severe(
          'Error: Expected value of key=${strings.libclang_dylib} to be a string');
      _setResult(CheckerResult.error);
    } else if (!File(map[strings.libclang_dylib] as String).existsSync()) {
      _logger.severe(
          'Error: ${map[strings.libclang_dylib] as String} does not exist');
      _setResult(CheckerResult.error);
    }
  } else {
    _logger.severe('Error: key ${strings.libclang_dylib} not found');
    _setResult(CheckerResult.error);
  }
}

// sets result according to priority
void _setResult(CheckerResult result) {
  if (_result != CheckerResult.error) {
    _result = result;
  }
}
