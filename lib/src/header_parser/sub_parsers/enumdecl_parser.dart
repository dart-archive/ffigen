// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

var _logger = Logger('ffigen.header_parser.enumdecl_parser');

/// Holds temporary information regarding [EnumClass] while parsing.
class _ParsedEnum {
  EnumClass enumClass;
  _ParsedEnum();
}

final _stack = Stack<_ParsedEnum>();

/// Parses a function declaration.
EnumClass parseEnumDeclaration(
  Pointer<clang_types.CXCursor> cursor, {

  /// Optionally provide name to use (useful in case struct is inside a typedef).
  String name,
}) {
  _stack.push(_ParsedEnum());

  final enumName = name ?? cursor.spelling();
  if (enumName == '') {
    _logger.finest('unnamed enum declaration');
  } else if (shouldIncludeEnumClass(enumName) && !isSeenEnumClass(enumName)) {
    _logger.fine('++++ Adding Enum: ${cursor.completeStringRepr()}');
    _stack.top.enumClass = EnumClass(
      dartDoc: getCursorDocComment(cursor),
      originalName: enumName,
      name: config.enumClassDecl.getPrefixedName(enumName),
    );
    addEnumClassToSeen(enumName, _stack.top.enumClass);
    _addEnumConstant(cursor);
  }

  return _stack.pop().enumClass;
}

void _addEnumConstant(Pointer<clang_types.CXCursor> cursor) {
  final resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
        _enumCursorVisitor, clang_types.CXChildVisitResult.CXChildVisit_Break),
    uid,
  );

  visitChildrenResultChecker(resultCode);
}

/// Visitor for a enum cursor [clang.CXCursorKind.CXCursor_EnumDecl].
///
/// Invoked on every enum directly under rootCursor.
/// Used for for extracting enum values.
int _enumCursorVisitor(Pointer<clang_types.CXCursor> cursor,
    Pointer<clang_types.CXCursor> parent, Pointer<Void> clientData) {
  try {
    _logger.finest('  enumCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
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
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

/// Adds the parameter to func in [functiondecl_parser.dart].
void _addEnumConstantToEnumClass(Pointer<clang_types.CXCursor> cursor) {
  _stack.top.enumClass.enumConstants.add(
    EnumConstant(
        dartDoc: getCursorDocComment(
          cursor,
          nesting.length + commentPrefix.length,
        ),
        name: cursor.spelling(),
        value: clang.clang_getEnumConstantDeclValue_wrap(cursor)),
  );
}
