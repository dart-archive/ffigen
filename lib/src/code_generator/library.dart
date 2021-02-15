// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'binding.dart';
import 'utils.dart';
import 'writer.dart';

final _logger = Logger('ffigen.code_generator.library');

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  final List<Binding> bindings;

  late Writer _writer;
  Writer get writer => _writer;

  Library({
    required String name,
    String? description,
    required this.bindings,
    String? header,
    bool dartBool = true,
  }) {
    // Seperate bindings which require lookup.
    final lookUpBindings = bindings.whereType<LookUpBinding>().toList();
    final noLookUpBindings = bindings.whereType<NoLookUpBinding>().toList();

    /// Handle any declaration-declaration name conflict in [lookUpBindings].
    final lookUpDeclConflictHandler = UniqueNamer({});
    for (final b in lookUpBindings) {
      _warnIfPrivateDeclaration(b);
      _resolveIfNameConflicts(lookUpDeclConflictHandler, b);
    }

    /// Handle any declaration-declaration name conflict in [noLookUpBindings].
    final noLookUpDeclConflictHandler = UniqueNamer({});
    for (final b in noLookUpBindings) {
      _warnIfPrivateDeclaration(b);
      _resolveIfNameConflicts(noLookUpDeclConflictHandler, b);
    }

    _writer = Writer(
      lookUpBindings: lookUpBindings,
      noLookUpBindings: noLookUpBindings,
      className: name,
      classDocComment: description,
      header: header,
      dartBool: dartBool,
    );
  }

  /// Logs a warning if generated declaration will be private.
  void _warnIfPrivateDeclaration(Binding b) {
    if (b.name.startsWith('_')) {
      _logger.warning(
          "Generated declaration '${b.name}' start's with '_' and therefore will be private.");
    }
  }

  /// Resolves name conflict(if any) and logs a warning.
  void _resolveIfNameConflicts(UniqueNamer namer, Binding b) {
    // Print warning if name was conflicting and has been changed.
    if (namer.isUsed(b.name)) {
      final oldName = b.name;
      b.name = namer.makeUnique(b.name);

      _logger.warning(
          "Resolved name conflict: Declaration '$oldName' and has been renamed to '${b.name}'.");
    } else {
      namer.markUsed(b.name);
    }
  }

  /// Sort all bindings in alphabetical order.
  void sort() {
    bindings.sort((b1, b2) => b1.name.compareTo(b2.name));
  }

  /// Generates [file] by generating C bindings.
  ///
  /// If format is true(default), 'dartfmt -w $PATH' will be called to format the generated file.
  void generateFile(File file, {bool format = true}) {
    file.writeAsStringSync(generate());
    if (format) {
      _dartFmt(file.path);
    }
  }

  /// Formats a file using `dartfmt`.
  void _dartFmt(String path) {
    final sdkPath = getSdkPath();
    final result = Process.runSync(
        p.join(sdkPath, 'bin', 'dart'), ['format', path],
        runInShell: Platform.isWindows);
    if (result.stderr.toString().isNotEmpty) {
      _logger.severe(result.stderr);
      throw FormatException('Unable to format generated file: $path.');
    }
  }

  /// Generates the bindings.
  String generate() {
    return writer.generate();
  }

  @override
  bool operator ==(Object o) => o is Library && o.generate() == generate();
}
