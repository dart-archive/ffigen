// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:wasmjsgen/src/code_generator.dart';
import 'package:wasmjsgen/src/config_provider/config_types.dart';

import 'binding.dart';
import 'struc.dart';
import 'utils.dart';
import 'writer.dart';

final _logger = Logger('wasmjsgen.code_generator.library');

// These don't fit in Javascript and thus cause compilation errors when targeting the web
const PROBLEMATIC_CONST_LITERALS = <String>{
  // Max values
  'INT64_MAX',
  'INT_LEAST64_MAX',
  'INT_FAST64_MAX',
  'INTPTR_MAX',
  'INTMAX_MAX',
  'PTRDIFF_MAX',
  'RSIZE_MAX',
  // Min values
  'INT64_MIN',
  'INT_LEAST64_MIN',
  'INT_FAST64_MIN',
  'INTPTR_MIN',
  'INTMAX_MIN',
  'PTRDIFF_MIN',
};

bool isProblematicConstLiteral(Binding b) {
  return b is Constant && PROBLEMATIC_CONST_LITERALS.contains(b.originalName);
}

bool hasInvalidPrefix(Binding b) {
  // _ prefixed methods and types from deps cause problems in some cases and
  // would become private anyways
  return b.name.startsWith('_');
}

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  late List<Binding> bindings;

  late Writer _writer;
  Library({
    required String name,
    String? description,
    required List<Binding> bindings,
    String? allocate,
    String? deallocate,
    String? reallocate,
    String? header,
    bool dartBool = true,
    bool sort = false,
    StructPackingOverride? packingOverride,
  }) {
    /// Get all dependencies (includes itself).
    final dependencies = <Binding>{};

    for (final b in bindings
        .where((b) => !isProblematicConstLiteral(b) && !hasInvalidPrefix(b))) {
      b.addDependencies(dependencies);
    }

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

    if (allocate == null) {
      _logger.warning(
          "No 'allocate' function specified. You won't be able allocate memory nor to pass strings to WASM.");
    }

    _writer = Writer(
      lookUpBindings: lookUpBindings,
      noLookUpBindings: noLookUpBindings,
      className: name,
      classDocComment: description,
      header: header,
      dartBool: dartBool,
      allocate: allocate,
      deallocate: deallocate,
      reallocate: reallocate,
    );
  }

  @override
  int get hashCode => bindings.hashCode;

  Writer get writer => _writer;

  @override
  bool operator ==(other) => other is Library && other.generate() == generate();

  /// Generates the bindings.
  String generate() {
    return writer.generate();
  }

  /// Generates [file] by generating C bindings.
  ///
  /// If format is true(default), the formatter will be called to format the generated file.
  void generateFile(File file, {bool format = true}) {
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsStringSync(generate());
    if (format) {
      _dartFormat(file.path);
    }
  }

  /// Formats a file using the Dart formatter.
  void _dartFormat(String path) {
    final sdkPath = getSdkPath();
    final result = Process.runSync(
        p.join(sdkPath, 'bin', 'dart'), ['format', path],
        runInShell: Platform.isWindows);
    if (result.stderr.toString().isNotEmpty) {
      _logger.severe(result.stderr);
      throw FormatException('Unable to format generated file: $path.');
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

  /// Logs a warning if generated declaration will be private.
  void _warnIfPrivateDeclaration(Binding b) {
    if (b.name.startsWith('_')) {
      _logger.warning(
          "Generated declaration '${b.name}' start's with '_' and therefore will be private.");
    }
  }
}
