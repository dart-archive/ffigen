import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import '../visitors/function_visitor.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../data.dart' as data;

/// Temporarily holds a function before its returned by [parseFunctionDeclaration]
Func func;

/// Parses a function declaration
Func parseFunctionDeclaration(Pointer<clang.CXCursor> cursor) {
  var name = cursor.spelling();
  if (data.config.functionFilters != null &&
      data.config.functionFilters.shouldInclude(name)) {
    printVerbose("Function: ${cursor.completeStringRepr()}");

    func = Func(
      name: name,
      returnType: _getFunctionReturnType(cursor),
    );
    _addParameters(cursor);
  }

  var f = func;
  func = null;
  return f;
}

Type _getFunctionReturnType(Pointer<clang.CXCursor> cursor) {
  return cursor.returnType().toCodeGenTypeAndDispose();
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
