import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/print.dart';

import '../includer.dart';
import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Temporarily holds a function before its returned by [parseFunctionDeclaration]
Func _func;

/// Parses a function declaration
Func parseFunctionDeclaration(Pointer<clang.CXCursor> cursor) {
  _func = null;

  var name = cursor.spelling();
  if (shouldIncludeFunc(name)) {
    printVerbose("Function: ${cursor.completeStringRepr()}");

    _func = Func(
      dartDoc: clang
          .clang_Cursor_getBriefCommentText_wrap(cursor)
          .toStringAndDispose(),
      name: name,
      returnType: _getFunctionReturnType(cursor),
    );
    _addParameters(cursor);
  }

  return _func;
}

Type _getFunctionReturnType(Pointer<clang.CXCursor> cursor) {
  return cursor.returnType().toCodeGenTypeAndDispose();
}

void _addParameters(Pointer<clang.CXCursor> cursor) {
  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
        _functionCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
}

/// Visitor for a function cursor [clang.CXCursorKind.CXCursor_FunctionDecl]
///
/// Invoked on every function directly under rootCursor
/// for extracting parameters
int _functionCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printExtraVerbose(
        '--functionCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_ParmDecl:
        _addParameterToFunc(cursor);
        break;
    }
    cursor.dispose();
    parent.dispose();
  } catch (e, s) {
    printError(e);
    printError(s);
    rethrow;
  }
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}

/// Adds the parameter to func in [functiondecl_parser.dart]
void _addParameterToFunc(Pointer<clang.CXCursor> cursor) {
  _func.parameters.add(
    Parameter(
      name: cursor.spelling(),
      type: _getParameterType(cursor),
    ),
  );
}

Type _getParameterType(Pointer<clang.CXCursor> cursor) {
  return cursor.type().toCodeGenTypeAndDispose();
}
