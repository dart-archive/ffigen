import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import '../sub_parsers/functiondecl_parser.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Visitor for a function cursor [clang.CXCursorKind.CXCursor_FunctionDecl]
///
/// Invoked on every function directly under rootCursor
int functionCursorVisitor(Pointer<clang.CXCursor> cursor,
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
  func.parameters.add(
    Parameter(
      name: cursor.spelling(),
      type: _getParameterType(cursor),
    ),
  );
}

Type _getParameterType(Pointer<clang.CXCursor> cursor) {
  return cursor.type().toCodeGenTypeAndDispose();
}
