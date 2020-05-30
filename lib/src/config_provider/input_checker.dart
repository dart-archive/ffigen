/// Validates the yaml input by the user,
/// prints useful info for the user
library input_checker;

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

CheckerResult checkYaml(YamlMap map) {
  _result = CheckerResult.correct;

  // TODO: Validate output file

  // validate libclang_dylib_path attribute
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

  // TODO: Validate headers

  // validate compiler-opts
  if (map.containsKey(strings.compilerOpts) &&
      map[strings.compilerOpts] is! String) {
    _logger.info(
        'Warning: Expected value of key=${strings.compilerOpts} to be a string, ${strings.compilerOpts} will be ignored');
    _setResult(CheckerResult.error);
  }

  // TODO: Validate filters

  // print unknown attributes
  List<String> unknownopts = [];
  for (var k in map.keys) {
    String key = k as String;
    if (!strings.mapOfAllOptions.containsKey(key)) {
      unknownopts.add(key);
    }
  }
  if (unknownopts.length > 0) {
    _logger.info('Warning: Unknown keys found - ' + unknownopts.join(', '));
    _setResult(CheckerResult.warnings);
  }

  return _result;
}

// sets result according to priority
void _setResult(CheckerResult result) {
  if (_result != CheckerResult.error) {
    _result = result;
  }
}