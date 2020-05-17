/// Visitor for the Root cursor [CXCursorKind.CXCursor_TranslationUnit]
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import 'function_visitor.dart';
import '../data.dart' as data;

/// child visitor invoked on translationUnitCursor
int rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('debug rootCursorVisitor: ${cursor.completeStringRepr()}');

  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_FunctionDecl:
      _createFunc(cursor);
      _addParameters(cursor);
      _addFuncToBinding();
      break;
    default:
      print('debug: Not Implemented');
  }

  free(parent);
  free(cursor);
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}

void _createFunc(Pointer<clang.CXCursor> cursor) {
  data.func = Func(
    name: cursor.spelling(),
    returnType: _getFunctionReturnType(cursor),
  );
}

Type _getFunctionReturnType(Pointer<clang.CXCursor> cursor) {
  return cursor.returnType().codeGenType();
}

void _addParameters(Pointer<clang.CXCursor> cursor) {
  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
        functionCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
}

void _addFuncToBinding() {
  data.bindings.add(data.func);
}
