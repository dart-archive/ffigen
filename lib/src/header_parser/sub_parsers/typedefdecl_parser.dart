import 'dart:ffi';

import '../visitors/typedefdecl_visitor.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Parses a typedef declaration
void parseTypedefDeclaration(Pointer<clang.CXCursor> cursor) {

  // set name of typedef (used later)
  typeDefNameFromParser = cursor.spelling();

  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(typedefdeclarationCursorVisitor,
        clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
}
