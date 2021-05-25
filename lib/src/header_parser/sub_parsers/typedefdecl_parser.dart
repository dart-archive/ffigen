// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../sub_parsers/enumdecl_parser.dart';
import '../utils.dart';
import 'compounddecl_parser.dart';

final _logger = Logger('ffigen.header_parser.typedefdecl_parser');

/// Holds temporary information regarding a typedef referenced [Binding]
/// while parsing.
///
/// Notes:
/// - Pointer to Typedefs structs are skipped if the struct is seen.
/// - If there are multiple typedefs for a declaration (struct/enum), the last
/// seen name is used.
/// - Typerefs are completely ignored.
///
/// Libclang marks them as following -
/// ```C
/// typedef struct A{
///   int a
/// } B, *pB; // Typedef(s).
///
/// typedef A D; // Typeref.
/// ```
class _ParsedTypedef {
  Binding? binding;
  String? typedefName;
  bool typedefToPointer = false;
  _ParsedTypedef();
}

final _stack = Stack<_ParsedTypedef>();

/// Parses a typedef declaration.
Binding? parseTypedefDeclaration(clang_types.CXCursor cursor) {
  _stack.push(_ParsedTypedef());

  /// Check if typedef declaration is to a pointer.
  _stack.top.typedefToPointer =
      (clang.clang_getTypedefDeclUnderlyingType(cursor).kind ==
          clang_types.CXTypeKind.CXType_Pointer);

  // Name of typedef.
  _stack.top.typedefName = cursor.spelling();
  final resultCode = clang.clang_visitChildren(
    cursor,
    Pointer.fromFunction(_typedefdeclarationCursorVisitor,
        clang_types.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
  return _stack.pop().binding;
}

/// Visitor for extracting binding for a TypedefDeclarations of a
/// [clang.CXCursorKind.CXCursor_TypedefDecl].
///
/// Visitor invoked on cursor of type declaration returned by
/// [clang.clang_getTypeDeclaration_wrap].
int _typedefdeclarationCursorVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  try {
    _logger.finest(
        'typedefdeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind(cursor)) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        if (_stack.top.typedefToPointer &&
            bindingsIndex.isSeenStruct(cursor.usr())) {
          // Skip a typedef pointer if struct is seen.
          _stack.top.binding = bindingsIndex.getSeenStruct(cursor.usr());
        } else {
          // This will update the name of struct if already seen.
          _stack.top.binding = parseCompoundDeclaration(
            cursor,
            CompoundType.struct,
          );
        }
        break;
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
        if (_stack.top.typedefToPointer &&
            bindingsIndex.isSeenUnion(cursor.usr())) {
          // Skip a typedef pointer if struct is seen.
          _stack.top.binding = bindingsIndex.getSeenUnion(cursor.usr());
        } else {
          // This will update the name of struct if already seen.
          _stack.top.binding = parseCompoundDeclaration(
            cursor,
            CompoundType.union,
          );
        }
        break;
      case clang_types.CXCursorKind.CXCursor_EnumDecl:
        _stack.top.binding = parseEnumDeclaration(cursor);
        break;
      default:
        _logger.finest('typedefdeclarationCursorVisitor: Ignored');
    }
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
