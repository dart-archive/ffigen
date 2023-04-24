// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import '../clang_bindings/clang_bindings.dart';
import '../data.dart';
import '../utils.dart';

/// This type holds the list of `ParmDecl` nodes of a function type declaration.
class FunctionTypeParams {
  final List<String> paramNames;
  final Map<String, CXCursor> params;
  FunctionTypeParams()
      : paramNames = [],
        params = {};
}

FunctionTypeParams? _params;

int _functionPointerFieldVisitor(
    CXCursor cursor, CXCursor parent, Pointer<Void> clientData) {
  if (cursor.kind == CXCursorKind.CXCursor_ParmDecl) {
    final spelling = cursor.spelling();
    if (spelling.isNotEmpty) {
      _params!.paramNames.add(spelling);
      _params!.params[spelling] = cursor;
      return CXChildVisitResult.CXChildVisit_Continue;
    } else {
      // A parameter's spelling is empty, do not continue further traversal.
      _params!.paramNames.clear();
      _params!.params.clear();
      return CXChildVisitResult.CXChildVisit_Break;
    }
  }
  // The cursor itself may be a pointer etc..
  return CXChildVisitResult.CXChildVisit_Recurse;
}

/// Returns `ParmDecl` nodes of function pointer declaration
/// directly or indirectly pointed to by [cursor].
FunctionTypeParams parseFunctionPointerParamNames(CXCursor cursor) {
  _params = FunctionTypeParams();
  clang.clang_visitChildren(
    cursor,
    Pointer.fromFunction(
        _functionPointerFieldVisitor, exceptional_visitor_return),
    nullptr,
  );
  final result = _params;
  _params = null;
  return result!;
}
