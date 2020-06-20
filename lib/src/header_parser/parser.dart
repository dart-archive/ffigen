// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser/translation_unit_parser.dart';
import 'package:logging/logging.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'data.dart' as data;
import 'utils.dart';

/// Main entrypoint for header_parser.
Library parse(Config conf, {bool sort = false}) {
  initParser(conf);

  final bindings = parseAndGenerateBindings();

  final library = Library(bindings: bindings);

  if (sort) {
    library.sort();
  }
  return library;
}

// ===================================================================================
//           BELOW FUNCTIONS ARE MEANT FOR INTERNAL USE AND TESTING
// ===================================================================================

var _logger = Logger('parser:parser');

/// initialises parser, clears any previous values.
void initParser(Config c) {
  data.config = c;

  clang.init(DynamicLibrary.open(data.config.libclang_dylib_path));
}

/// Parses source files and adds generated bindings to [bindings].
List<Binding> parseAndGenerateBindings() {
  final index = clang.clang_createIndex(0, 0);

  Pointer<Pointer<Utf8>> clangCmdArgs = nullptr;
  var cmdLen = 0;
  if (data.config.compilerOpts != null) {
    clangCmdArgs = createDynamicStringArray(data.config.compilerOpts);
    cmdLen = data.config.compilerOpts.length;
  }

  // Contains all bindings.
  final bindings = <Binding>[];

  for (final h in data.config.headers) {
    final headerLocation = h;
    _logger.fine('Creating TranslationUnit for header: $headerLocation');

    final tu = clang.clang_parseTranslationUnit(
      index,
      Utf8.toUtf8(headerLocation).cast(),
      clangCmdArgs.cast(),
      cmdLen,
      nullptr,
      0,
      clang.CXTranslationUnit_Flags.CXTranslationUnit_SkipFunctionBodies,
    );

    if (tu == nullptr) {
      throw Exception(
          'Error creating Translation unit for header: $headerLocation');
    }

    logTuDiagnostics(tu, _logger, headerLocation);
    final rootCursor = clang.clang_getTranslationUnitCursor_wrap(tu);

    bindings.addAll(parseTranslationUnitCursor(rootCursor));

    // cleanup
    rootCursor.dispose();
    clang.clang_disposeTranslationUnit(tu);
  }

  if (data.config.compilerOpts != null) {
    clangCmdArgs.dispose(data.config.compilerOpts.length);
  }
  clang.clang_disposeIndex(index);
  return bindings;
}
