/// Visitor for the function type cursor [clang.CXCursorKind.CXCursor_FunctionDecl]
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

int functionCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('  debug functionCursorVisitor: ${cursorAsString(cursor)}');
  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_ParmDecl:
      break;
    default:
      print('debug: Not Implemented');
  }
  free(parent);
  free(cursor);
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}
