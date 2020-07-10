// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'binding.dart';
import 'utils.dart';
import 'writer.dart';

var _logger = Logger('code_generator:library.dart');

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
      // Print warning if name was conflicting and has been changed.
      if (lookUpDeclConflictHandler.isUsed(b.name)) {
        final oldName = b.name;
        b.name = lookUpDeclConflictHandler.makeUnique(b.name);

        _logger.warning(
            "Resolved name conflict: Declaration '$oldName' and has been renamed to '${b.name}'.");
      } else {
        lookUpDeclConflictHandler.markUsed(b.name);
      }
    }

    /// Handle any declaration-declaration name conflict in [noLookUpBindings].
    final noLookUpDeclConflictHandler = UniqueNamer({});
    for (final b in noLookUpBindings) {
      // Print warning if name was conflicting and has been changed.
      if (noLookUpDeclConflictHandler.isUsed(b.name)) {
        final oldName = b.name;
        b.name = noLookUpDeclConflictHandler.makeUnique(b.name);

        _logger.warning(
            "Resolved name conflict: Declaration '$oldName' and has been renamed to '${b.name}'.");
      } else {
        noLookUpDeclConflictHandler.markUsed(b.name);
      }
    }

    _writer = Writer(
      lookUpBindings: lookUpBindings,
      noLookUpBindings: noLookUpBindings,
      className: name,
      classDocComment: description,
      header: header,
    );
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
