// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'binding.dart';
import 'struc.dart';
import 'utils.dart';
import 'writer.dart';

final _logger = Logger('ffigen.code_generator.library');

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  late List<Binding> bindings;

  late Writer _writer;
  Writer get writer => _writer;

  Library({
    required String name,
    String? description,
    required List<Binding> bindings,
    String? header,
    bool dartBool = true,
    bool sort = false,
    StructPackingOverride? packingOverride,
  }) {
    /// Get all dependencies (includes itself).
    final dependencies = <Binding>{};
    bindings.forEach((b) => b.addDependencies(dependencies));

    /// Save bindings.
    this.bindings = dependencies.toList();

    if (sort) {
      _sort();
    }

    /// Handle any declaration-declaration name conflicts.
    final declConflictHandler = UniqueNamer({});
    for (final b in this.bindings) {
      _warnIfPrivateDeclaration(b);
      _resolveIfNameConflicts(declConflictHandler, b);
    }

    // Override pack values according to config. We do this after declaration
    // conflicts have been handled so that users can target the generated names.
    if (packingOverride != null) {
      for (final b in this.bindings) {
        if (b is Struc && packingOverride.isOverriden(b.name)) {
          b.pack = packingOverride.getOverridenPackValue(b.name);
        }
      }
    }

    // Seperate bindings which require lookup.
    final lookUpBindings = this.bindings.whereType<LookUpBinding>().toList();
    final noLookUpBindings =
        this.bindings.whereType<NoLookUpBinding>().toList();

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
  void _sort() {
    bindings.sort((b1, b2) => b1.name.compareTo(b2.name));
  }

  /// Generates [file] by generating C bindings.
  ///
  /// If format is true(default), 'dartfmt -w $PATH' will be called to format the generated file.
  void generateFile(File file, {bool format = true}) {
    if (!file.existsSync()) file.createSync(recursive: true);
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
