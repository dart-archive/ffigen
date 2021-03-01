// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

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

/// Generates actual file using library and tests using [expect] with expected
///
/// This will not delete the actual debug file incase [expect] throws an error.
void matchLibraryWithExpected(
    Library library, List<String> pathForActual, List<String> pathToExpected) {
  final file = File(
    path.joinAll(pathForActual),
  );
  library.generateFile(file);

  try {
    final actual = file.readAsStringSync();
    final expected = File(path.joinAll(pathToExpected)).readAsStringSync();
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
