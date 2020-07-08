// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'includer.dart';
import 'sub_parsers/enumdecl_parser.dart';
import 'sub_parsers/functiondecl_parser.dart';
import 'sub_parsers/structdecl_parser.dart';
import 'sub_parsers/typedefdecl_parser.dart';
import 'utils.dart';

var _logger = Logger('header_parser:translation_unit_parser.dart');

List<Binding> _bindings;

/// Parses the translation unit and returns the generated bindings.
List<Binding> parseTranslationUnit(Pointer<clang.CXCursor> translationUnitCursor) {
  _bindings = [];

  final resultCode = clang.clang_visitChildren_wrap(
    translationUnitCursor,
    Pointer.fromFunction(
        _rootCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  return _bindings;
}

/// Child visitor invoked on translationUnitCursor [CXCursorKind.CXCursor_TranslationUnit].
int _rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    if (shouldIncludeRootCursor(cursor.sourceFileName())) {
      _logger.finest('rootCursorVisitor: ${cursor.completeStringRepr()}');
      switch (clang.clang_getCursorKind_wrap(cursor)) {
        case clang.CXCursorKind.CXCursor_FunctionDecl:
          addToBindings(parseFunctionDeclaration(cursor));
          break;
        case clang.CXCursorKind.CXCursor_TypedefDecl:
          addToBindings(parseTypedefDeclaration(cursor));
          break;
        case clang.CXCursorKind.CXCursor_StructDecl:
          addToBindings(parseStructDeclaration(cursor));
          break;
        case clang.CXCursorKind.CXCursor_EnumDecl:
          addToBindings(parseEnumDeclaration(cursor));
          break;
        default:
          _logger.finer('rootCursorVisitor: CursorKind not implemented');
      }
    } else {
      _logger.finest(
          'rootCursorVisitor:(excluded in header-filter) ${cursor.completeStringRepr()}');
    }

    cursor.dispose();
    parent.dispose();
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}

/// Adds to binding if not null.
void addToBindings(Binding b) {
  if (b != null) {
    _bindings.add(b);
  }
}
