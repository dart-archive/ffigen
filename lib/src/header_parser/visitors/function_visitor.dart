/// Visitor for the function type cursor [clang.CXCursorKind.CXCursor_FunctionDecl]
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../data.dart' as data;

int functionCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    print('  debug functionCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_ParmDecl:
        _addParameterToLastFunc(cursor);
        break;
      default:
        print('debug: Not Implemented');
    }
    free(parent);
    free(cursor);
  } catch (e, s) {
    print(e);
    print(s);
    rethrow;
  }
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}

/// Adds the parameter to [data.func]
void _addParameterToLastFunc(Pointer<clang.CXCursor> cursor) {
  data.func.parameters.add(
    Parameter(
      name: cursor.spelling(),
      type: _getParameterType(cursor),
    ),
  );
}

Type _getParameterType(Pointer<clang.CXCursor> cursor) {
  return cursor.type().codeGenType();
}
