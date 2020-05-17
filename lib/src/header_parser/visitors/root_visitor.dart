/// Visitor for the Root cursor [CXCursorKind.CXCursor_TranslationUnit]
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import 'function_visitor.dart';

int rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('debug rootCursorVisitor: ${cursorAsString(cursor)}');
  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_FunctionDecl:
      clang.clang_visitChildren_wrap(
        cursor,
        Pointer.fromFunction(
            functionCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
        nullptr,
      );
      break;
    default:
      print('debug: Not Implemented');
  }

  free(parent);
  free(cursor);
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}
