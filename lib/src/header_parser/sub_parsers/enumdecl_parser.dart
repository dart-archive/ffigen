// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/sub_parsers/unnamed_enumdecl_parser.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.enumdecl_parser');

/// Holds temporary information regarding [EnumClass] while parsing.
class _ParsedEnum {
  EnumClass? enumClass;
  _ParsedEnum();
}

final _stack = Stack<_ParsedEnum>();

/// Parses a function declaration.
EnumClass? parseEnumDeclaration(
  clang_types.CXCursor cursor, {

  /// Optionally provide name to use (useful in case enum is inside a typedef).
  String? name,
}) {
  _stack.push(_ParsedEnum());
  final enumUsr = cursor.usr();
  final enumName = name ?? cursor.spelling();
  if (enumName == '') {
    // Save this unnamed enum if it is anonymous (therefore not in a typedef).
    if (clang.clang_Cursor_isAnonymous(cursor) != 0) {
      _logger.fine('Saving anonymous enum.');
      saveUnNamedEnum(cursor);
    } else {
      _logger.fine('Unnamed enum inside a typedef.');
    }
  } else if (shouldIncludeEnumClass(enumUsr, enumName)) {
    _logger.fine('++++ Adding Enum: ${cursor.completeStringRepr()}');
    _stack.top.enumClass = EnumClass(
      usr: enumUsr,
      dartDoc: getCursorDocComment(cursor),
      originalName: enumName,
      name: config.enumClassDecl.renameUsingConfig(enumName),
    );
    bindingsIndex.addEnumClassToSeen(enumUsr, _stack.top.enumClass!);
    _addEnumConstant(cursor);
  }
  if (bindingsIndex.isSeenEnumClass(enumUsr)) {
    _stack.top.enumClass = bindingsIndex.getSeenEnumClass(enumUsr);

    // If enum is seen, update it's name.
    _stack.top.enumClass!.name =
        config.enumClassDecl.renameUsingConfig(enumName);
  }

  return _stack.pop().enumClass;
}

void _addEnumConstant(clang_types.CXCursor cursor) {
  final resultCode = clang.clang_visitChildren(
    cursor,
    Pointer.fromFunction(
        _enumCursorVisitor, clang_types.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
}

/// Visitor for a enum cursor [clang.CXCursorKind.CXCursor_EnumDecl].
///
/// Invoked on every enum directly under rootCursor.
/// Used for for extracting enum values.
int _enumCursorVisitor(clang_types.CXCursor cursor, clang_types.CXCursor parent,
    Pointer<Void> clientData) {
  try {
    _logger.finest('  enumCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind(cursor)) {
      case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
        _addEnumConstantToEnumClass(cursor);
        break;
      default:
        _logger.fine('invalid enum constant');
    }
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

/// Adds the parameter to func in [functiondecl_parser.dart].
void _addEnumConstantToEnumClass(clang_types.CXCursor cursor) {
  _stack.top.enumClass!.enumConstants.add(
    EnumConstant(
        dartDoc: getCursorDocComment(
          cursor,
          nesting.length + commentPrefix.length,
        ),
        originalName: cursor.spelling(),
        name: config.enumClassDecl.renameMemberUsingConfig(
          _stack.top.enumClass!.originalName,
          cursor.spelling(),
        ),
        value: clang.clang_getEnumConstantDeclValue(cursor)),
  );
}
