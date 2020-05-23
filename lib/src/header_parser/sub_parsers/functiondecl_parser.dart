import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import '../visitors/function_visitor.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../data.dart' as data;

/// Parses a function declaration
void parseFunctionDeclaration(Pointer<clang.CXCursor> cursor) {
  var name = cursor.spelling();
  if (data.config.functionFilters != null &&
      data.config.functionFilters.shouldInclude(name)) {
    printVerbose("Function: ${cursor.completeStringRepr()}");

    data.func = Func(
      name: name,
      returnType: _getFunctionReturnType(cursor),
    );
    _addParameters(cursor);
    _addFuncToBinding();
  }
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

void _addFuncToBinding() {
  data.bindings.add(data.func);
}
