import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';

import '../visitors/typedefdecl_visitor.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Temporarily holds a binding before its returned by [parseTypedefDeclaration]
Binding binding;

/// Temporarily holds parent cursor name (used in typedefdecl_visitor.dart)
String typedefName;

/// Parses a typedef declaration
Binding parseTypedefDeclaration(Pointer<clang.CXCursor> cursor) {
  // set name of typedef (used later)
  typedefName = cursor.spelling();

  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(typedefdeclarationCursorVisitor,
        clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  var b = binding;
  binding = null;
  return b;
}
