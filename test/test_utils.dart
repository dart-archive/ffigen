// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

extension LibraryTestExt on Library {
  /// Get a [Binding]'s generated string with a given name.
  String getBindingAsString(String name) {
    try {
      final b = bindings.firstWhere((element) => element.name == name);
      return b.toBindingString(writer).string;
    } catch (e) {
      throw NotFoundException("Binding '$name' not found.");
    }
  }

  /// Get a [Binding] with a given name.
  Binding getBinding(String name) {
    try {
      final b = bindings.firstWhere((element) => element.name == name);
      return b;
    } catch (e) {
      throw NotFoundException("Binding '$name' not found.");
    }
  }
}

/// Check whether a file generated by test/setup.dart exists and throw a helpful
/// exception if it does not.
void verifySetupFile(File file) {
  if (!file.existsSync()) {
    throw NotFoundException("The file ${file.path} does not exist.\n\n"
        "You may need to run: dart run test/setup.dart\n");
  }
}

// Remove '\r' for Windows compatibility, then apply user's normalizer.
String _normalizeGeneratedCode(
    String generated, String Function(String)? codeNormalizer) {
  final noCR = generated.replaceAll('\r', '').replaceAll(RegExp(r'\n+'), '\n');
  if (codeNormalizer == null) return noCR;
  return codeNormalizer(noCR);
}

/// Generates actual file using library and tests using [expect] with expected.
///
/// This will not delete the actual debug file incase [expect] throws an error.
void matchLibraryWithExpected(
    Library library, String pathForActual, List<String> pathToExpected,
    {String Function(String)? codeNormalizer}) {
  _matchFileWithExpected(
    library: library,
    pathForActual: pathForActual,
    pathToExpected: pathToExpected,
    fileWriter: ({required Library library, required File file}) =>
        library.generateFile(file),
    codeNormalizer: codeNormalizer,
  );
}

/// Generates actual file using library and tests using [expect] with expected.
///
/// This will not delete the actual debug file incase [expect] throws an error.
void matchLibrarySymbolFileWithExpected(Library library, String pathForActual,
    List<String> pathToExpected, String importPath) {
  _matchFileWithExpected(
      library: library,
      pathForActual: pathForActual,
      pathToExpected: pathToExpected,
      fileWriter: ({required Library library, required File file}) {
        if (!library.writer.canGenerateSymbolOutput) library.generate();
        library.generateSymbolOutputFile(file, importPath);
      });
}

/// Generates actual file using library and tests using [expect] with expected.
///
/// This will not delete the actual debug file incase [expect] throws an error.
void _matchFileWithExpected({
  required Library library,
  required String pathForActual,
  required List<String> pathToExpected,
  required void Function({required Library library, required File file})
      fileWriter,
  String Function(String)? codeNormalizer,
}) {
  final file = File(
    path.join(strings.tmpDir, pathForActual),
  );
  fileWriter(library: library, file: file);
  try {
    final actual =
        _normalizeGeneratedCode(file.readAsStringSync(), codeNormalizer);
    final expected = _normalizeGeneratedCode(
        File(path.joinAll(pathToExpected)).readAsStringSync(), codeNormalizer);
    expect(actual, expected);
    if (file.existsSync()) {
      file.delete();
    }
  } catch (e) {
    print('Failed test: Debug generated file: ${file.absolute.path}');
    rethrow;
  }
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() {
    return message;
  }
}

void logWarnings([Level level = Level.WARNING]) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name.padRight(8)}: ${record.message}');
  });
}

void logWarningsToArray(List<String> logArr, [Level level = Level.WARNING]) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    logArr.add('${record.level.name.padRight(8)}: ${record.message}');
  });
}

Config testConfig(String yamlBody, {String? filename}) {
  return Config.fromYaml(
    yaml.loadYaml(yamlBody) as yaml.YamlMap,
    filename: filename,
  );
}

Config testConfigFromPath(String path) {
  final file = File(path);
  final yamlBody = file.readAsStringSync();
  return testConfig(yamlBody, filename: path);
}
