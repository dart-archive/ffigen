// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'binding.dart';
import 'utils.dart';
import 'writer.dart';

var _logger = Logger('ffigen.code_generator.library');

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  final List<Binding> bindings;

  Writer _writer;
  Writer get writer => _writer;

  Library({
    @required String name,
    String description,
    @required this.bindings,
    String header,
  }) {
    // Seperate bindings which require lookup.
    final lookUpBindings = bindings.whereType<LookUpBinding>().toList();
    final noLookUpBindings = bindings.whereType<NoLookUpBinding>().toList();

    /// Handle any declaration-declaration name conflict in [lookUpBindings].
    final lookUpDeclConflictHandler = UniqueNamer({});
    for (final b in lookUpBindings) {
      _warnPrivateDeclaration(b);
      _resolveNameConflict(lookUpDeclConflictHandler, b);
    }

    /// Handle any declaration-declaration name conflict in [noLookUpBindings].
    final noLookUpDeclConflictHandler = UniqueNamer({});
    for (final b in noLookUpBindings) {
      _warnPrivateDeclaration(b);
      _resolveNameConflict(noLookUpDeclConflictHandler, b);
    }

    _writer = Writer(
      lookUpBindings: lookUpBindings,
      noLookUpBindings: noLookUpBindings,
      className: name,
      classDocComment: description,
      header: header,
    );
  }

  /// Logs a warning if generated declaration will be private.
  void _warnPrivateDeclaration(Binding b) {
    if (b.name.startsWith('_')) {
      _logger.warning(
          "Generated declaration '${b.name}' start's with '_' and therefore will be private.");
    }
  }

  /// LResolves name conflict(if any) and logs a warning.
  void _resolveNameConflict(UniqueNamer namer, Binding b) {
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
    final result = Process.runSync('dartfmt', ['-w', path],
        runInShell: Platform.isWindows);
    if (result.stderr.toString().isNotEmpty) {
      _logger.severe(result.stderr);
    }
  }

  /// Generates the bindings.
  String generate() {
    final w = writer;
    return w.generate();
  }

  @override
  bool operator ==(Object o) => o is Library && o.generate() == generate();
}
