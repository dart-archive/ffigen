// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'binding.dart';
import 'writer.dart';

var _logger = Logger('code_generator');

/// Container for all Bindings.
class Library {
  /// Variable identifier used for dynamicLibrary. Defaults to `_dylib`,
  final String dylibIdentifier;

  /// Init function for providing dynamic library. Defaults to `init`,
  ///
  /// Can be renamed in case of name conflicts with something else.
  final String initFunctionIdentifier;

  /// Name of the import prefix to use for dart:ffi
  final String ffiLibraryPrefix;

  /// Prefix for functions
  final String functionPrefix;

  /// Prefix for structs
  final String structPrefix;

  /// Prefix for struct members.
  final String structMemberPrefix;

  /// Prefix for enums.
  final String enumPrefix;

  /// Prefix for enum members.
  final String enumMemberPrefix;

  /// Prefix for Array helper classes.
  final String arrayHelperClassPrefix;

  /// Header of file.
  final String header;

  /// List of bindings in this library.
  final List<Binding> bindings;

  Writer _writer;
  Writer get writer {
    return _writer ??= Writer(
      dylibIdentifier: dylibIdentifier,
      initFunctionIdentifier: initFunctionIdentifier,
      ffiLibraryPrefix: ffiLibraryPrefix,
      functionPrefix: functionPrefix,
      structPrefix: structPrefix,
      structMemberPrefix: structMemberPrefix,
      enumPrefix: enumPrefix,
      enumMemberPrefix: enumMemberPrefix,
      header: header,
      arrayHelperClassPrefix: arrayHelperClassPrefix,
    );
  }

  Library({
    @required this.bindings,
    this.dylibIdentifier = '_dylib',
    this.initFunctionIdentifier = 'init',
    this.ffiLibraryPrefix = 'ffi',
    this.functionPrefix = '',
    this.structPrefix = '',
    this.structMemberPrefix = '',
    this.enumPrefix = '',
    this.enumMemberPrefix = '',
    this.arrayHelperClassPrefix = '',
    this.header,
  });

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

  /// Generates bindings and stores it in given [Writer].
  void _generate(Writer w) {
    for (final b in bindings) {
      w.addBindingString(b.toBindingString(w));
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
    _generate(w);
    return w.generate();
  }

  @override
  bool operator ==(Object o) => o is Library && o.generate() == generate();
}
