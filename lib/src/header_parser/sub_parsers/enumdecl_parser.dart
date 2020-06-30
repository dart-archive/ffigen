// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../includer.dart';
import '../utils.dart';

var _logger = Logger('parser:enumdecl_parser');

/// Temporarily holds a enumClass before its returned by [parseEnumDeclaration].
EnumClass _enumClass;

/// Parses a function declaration.
EnumClass parseEnumDeclaration(
  Pointer<clang.CXCursor> cursor, {

  /// Optionally provide name to use (useful in case struct is inside a typedef).
  String name,
}) {
  _enumClass = null;

  final enumName = name ?? cursor.spelling();
  if (enumName == '') {
    _logger.finest('unnamed enum declaration');
  } else if (shouldIncludeEnumClass(enumName)) {
    _logger.fine('++++ Adding Enum: ${cursor.completeStringRepr()}');
    _enumClass = EnumClass(
      dartDoc: getCursorDocComment(cursor),
      name: enumName,
    );
    _addEnumConstant(cursor);
  }

  return _enumClass;
}

void _addEnumConstant(Pointer<clang.CXCursor> cursor) {
  final resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
        _enumCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
}

/// Visitor for a enum cursor [clang.CXCursorKind.CXCursor_EnumDecl].
///
/// Invoked on every enum directly under rootCursor.
/// Used for for extracting enum values.
int _enumCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    _logger.finest('  enumCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_EnumConstantDecl:
        _addEnumConstantToEnumClass(cursor);
        break;
      default:
        print('invalid enum constant');
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

/// Adds the parameter to func in [functiondecl_parser.dart].
void _addEnumConstantToEnumClass(Pointer<clang.CXCursor> cursor) {
  _enumClass.enumConstants.add(
    EnumConstant(
        dartDoc: getCursorDocComment(
          cursor,
          nesting.length + commentPrefix.length,
        ),
        name: cursor.spelling(),
        value: clang.clang_getEnumConstantDeclValue_wrap(cursor)),
  );
}
