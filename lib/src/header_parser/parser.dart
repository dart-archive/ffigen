// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser/sub_parsers/macro_parser.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/translation_unit_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';

import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'data.dart';
import 'utils.dart';

/// Main entrypoint for header_parser.
Library parse(Config c) {
  initParser(c);

  final bindings = parseToBindings();

  final library = Library(
    bindings: bindings,
    name: config.wrapperName,
    description: config.wrapperDocComment,
    header: config.preamble,
    dartBool: config.dartBool,
    sort: config.sort,
    packingOverride: config.structPackingOverride,
  );

  return library;
}

// ===================================================================================
//           BELOW FUNCTIONS ARE MEANT FOR INTERNAL USE AND TESTING
// ===================================================================================

final _logger = Logger('ffigen.header_parser.parser');

/// Initializes parser, clears any previous values.
void initParser(Config c) {
  // Initialize global variables.
  initializeGlobals(
    config: c,
  );
}

/// Parses source files and adds generated bindings to [bindings].
List<Binding> parseToBindings() {
  final index = clang.clang_createIndex(0, 0);

  Pointer<Pointer<Utf8>> clangCmdArgs = nullptr;
  var cmdLen = 0;

  /// Add compiler opt for comment parsing for clang based on config.
  if (config.commentType.length != CommentLength.none &&
      config.commentType.style == CommentStyle.any) {
    config.compilerOpts.add(strings.fparseAllComments);
  }

  _logger.fine('CompilerOpts used: ${config.compilerOpts}');
  clangCmdArgs = createDynamicStringArray(config.compilerOpts);
  cmdLen = config.compilerOpts.length;

  // Contains all bindings. A set ensures we never have duplicates.
  final bindings = <Binding>{};

  // Log all headers for user.
  _logger.info('Input Headers: ${config.headers.entryPoints}');

  for (final headerLocation in config.headers.entryPoints) {
    _logger.fine('Creating TranslationUnit for header: $headerLocation');

    final tu = clang.clang_parseTranslationUnit(
      index,
      headerLocation.toNativeUtf8().cast(),
      clangCmdArgs.cast(),
      cmdLen,
      nullptr,
      0,
      clang_types.CXTranslationUnit_Flags.CXTranslationUnit_SkipFunctionBodies |
          clang_types.CXTranslationUnit_Flags
              .CXTranslationUnit_DetailedPreprocessingRecord,
    );

    if (tu == nullptr) {
      _logger.severe(
          "Skipped header/file: $headerLocation, couldn't parse source.");
      // Skip parsing this header.
      continue;
    }

    logTuDiagnostics(tu, _logger, headerLocation);
    final rootCursor = clang.clang_getTranslationUnitCursor(tu);

    bindings.addAll(parseTranslationUnit(rootCursor));

    // Cleanup.
    clang.clang_disposeTranslationUnit(tu);
  }

  // Add all saved unnamed enums.
  bindings.addAll(unnamedEnumConstants);

  // Parse all saved macros.
  bindings.addAll(parseSavedMacros()!);

  clangCmdArgs.dispose(config.compilerOpts.length);
  clang.clang_disposeIndex(index);
  return bindings.toList();
}
