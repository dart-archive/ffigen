import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import '../visitors/typedefdecl_visitor.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../data.dart' as data;

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
