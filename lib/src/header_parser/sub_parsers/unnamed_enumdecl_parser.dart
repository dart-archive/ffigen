// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/includer.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.unnamed_enumdecl_parser');

/// Saves unnamed enums.
void saveUnNamedEnum(Pointer<clang_types.CXCursor> cursor) {
  final resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(_unnamedenumCursorVisitor,
        clang_types.CXChildVisitResult.CXChildVisit_Break),
    uid,
  );

  visitChildrenResultChecker(resultCode);
}

/// Visitor for a enum cursor [clang.CXCursorKind.CXCursor_EnumDecl].
///
/// Invoked on every enum directly under rootCursor.
/// Used for for extracting enum values.
int _unnamedenumCursorVisitor(Pointer<clang_types.CXCursor> cursor,
    Pointer<clang_types.CXCursor> parent, Pointer<Void> clientData) {
  try {
    _logger
        .finest('  unnamedenumCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang_types.CXCursorKind.CXCursor_EnumConstantDecl:
        if (shouldIncludeUnnamedEnumConstant(cursor.usr(), cursor.spelling())) {
          _addUnNamedEnumConstant(cursor);
        }
        break;
      default:
        _logger.severe('Invalid enum constant.');
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
void _addUnNamedEnumConstant(Pointer<clang_types.CXCursor> cursor) {
  unnamedEnumConstants.add(
    Constant(
      usr: cursor.usr(),
      originalName: cursor.spelling(),
      name: config.unnamedEnumConstants.renameUsingConfig(
        cursor.spelling(),
      ),
      rawType: 'int',
      rawValue: clang.clang_getEnumConstantDeclValue_wrap(cursor).toString(),
    ),
  );
}
