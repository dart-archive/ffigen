// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart' show clang;
import '../sub_parsers/enumdecl_parser.dart';
import '../sub_parsers/structdecl_parser.dart';
import '../utils.dart';

var _logger = Logger('header_parser:typedefdecl_parser.dart');

/// Holds all data required while parsing a typedef decl.
class _Holder {
  Binding binding;
  String typedefName;
  _Holder();
}

/// Temporarily holds the binding before its returned by [parseTypedefDeclaration].
///
/// Maintained like a Stack.
List<_Holder> _holders = [];
_Holder get _current => _holders.last;
_Holder _getCurrentAndDispose() => _holders.removeLast();
void _addNewHolder() => _holders.add(_Holder());

/// Parses a typedef declaration.
Binding parseTypedefDeclaration(Pointer<clang_types.CXCursor> cursor) {
  _addNewHolder();
  // Name of typedef.
  _current.typedefName = cursor.spelling();

  final resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(_typedefdeclarationCursorVisitor,
        clang_types.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
  return _getCurrentAndDispose().binding;
}

/// Visitor for extracting binding for a TypedefDeclarations of a
/// [clang.CXCursorKind.CXCursor_TypedefDecl].
///
/// Visitor invoked on cursor of type declaration returned by
/// [clang.clang_getTypeDeclaration_wrap].
int _typedefdeclarationCursorVisitor(Pointer<clang_types.CXCursor> cursor,
    Pointer<clang_types.CXCursor> parent, Pointer<Void> clientData) {
  try {
    _logger.finest(
        'typedefdeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        _current.binding =
            parseStructDeclaration(cursor, name: _current.typedefName);
        break;
      case clang_types.CXCursorKind.CXCursor_EnumDecl:
        _current.binding =
            parseEnumDeclaration(cursor, name: _current.typedefName);
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
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
