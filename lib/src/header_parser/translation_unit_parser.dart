// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/sub_parsers/macro_parser.dart';
import 'package:logging/logging.dart';

import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'data.dart';
import 'includer.dart';
import 'sub_parsers/enumdecl_parser.dart';
import 'sub_parsers/functiondecl_parser.dart';
import 'sub_parsers/structdecl_parser.dart';
import 'sub_parsers/typedefdecl_parser.dart';
import 'utils.dart';

final _logger = Logger('ffigen.header_parser.translation_unit_parser');

Set<Binding>? _bindings;

/// Parses the translation unit and returns the generated bindings.
Set<Binding>? parseTranslationUnit(
    Pointer<clang_types.CXCursor> translationUnitCursor) {
  _bindings = {};
  final resultCode = clang.clang_visitChildren_wrap(
    translationUnitCursor,
    Pointer.fromFunction(
        _rootCursorVisitor, clang_types.CXChildVisitResult.CXChildVisit_Break),
    uid,
  );

  visitChildrenResultChecker(resultCode);

  return _bindings;
}

/// Child visitor invoked on translationUnitCursor [CXCursorKind.CXCursor_TranslationUnit].
int _rootCursorVisitor(Pointer<clang_types.CXCursor> cursor,
    Pointer<clang_types.CXCursor> parent, Pointer<Void> clientData) {
  try {
    if (shouldIncludeRootCursor(cursor.sourceFileName())) {
      _logger.finest('rootCursorVisitor: ${cursor.completeStringRepr()}');
      switch (clang.clang_getCursorKind_wrap(cursor)) {
        case clang_types.CXCursorKind.CXCursor_FunctionDecl:
          addToBindings(parseFunctionDeclaration(cursor));
          break;
        case clang_types.CXCursorKind.CXCursor_TypedefDecl:
          addToBindings(parseTypedefDeclaration(cursor));
          break;
        case clang_types.CXCursorKind.CXCursor_StructDecl:
          addToBindings(parseStructDeclaration(cursor));
          break;
        case clang_types.CXCursorKind.CXCursor_EnumDecl:
          addToBindings(parseEnumDeclaration(cursor));
          break;
        case clang_types.CXCursorKind.CXCursor_MacroDefinition:
          saveMacroDefinition(cursor);
          break;
        default:
          _logger.finer('rootCursorVisitor: CursorKind not implemented');
      }
    } else {
      _logger.finest(
          'rootCursorVisitor:(not included) ${cursor.completeStringRepr()}');
    }

    cursor.dispose();
    parent.dispose();
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

/// Adds to binding if unseen and not null.
void addToBindings(Binding? b) {
  if (b != null) {
    // This is a set, and hence will not have duplicates.
    _bindings!.add(b);
  }
}
