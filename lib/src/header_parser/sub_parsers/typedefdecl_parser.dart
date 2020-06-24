// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../sub_parsers/enumdecl_parser.dart';
import '../sub_parsers/structdecl_parser.dart';
import '../utils.dart';

var _logger = Logger('parser:typedefdecl_parser');

/// Temporarily holds a binding before its returned by [parseTypedefDeclaration].
Binding _binding;

/// Temporarily holds parent cursor name.
String _typedefName;

/// Parses a typedef declaration.
Binding parseTypedefDeclaration(Pointer<clang.CXCursor> cursor) {
  _binding = null;
  // Name of typedef.
  _typedefName = cursor.spelling();

  final resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(_typedefdeclarationCursorVisitor,
        clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  return _binding;
}

/// Visitor for extracting binding for a TypedefDeclarations of a
/// [clang.CXCursorKind.CXCursor_TypedefDecl].
///
/// Visitor invoked on cursor of type declaration returned by
/// [clang.clang_getTypeDeclaration_wrap].
int _typedefdeclarationCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    _logger.finest(
        'typedefdeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_StructDecl:
        _binding = parseStructDeclaration(cursor, name: _typedefName);
        break;
      case clang.CXCursorKind.CXCursor_EnumDecl:
        _binding = parseEnumDeclaration(cursor, name: _typedefName);
        break;
      default:
        _logger.finest('typedefdeclarationCursorVisitor: Ignored');
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
