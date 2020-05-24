import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

import '../sub_parsers/structdecl_parser.dart';
import 'package:ffigen/src/print.dart';

/// Temporarily holds a binding before its returned by [parseTypedefDeclaration]
Binding _binding;

/// Temporarily holds parent cursor name (used in typedefdecl_visitor.dart)
String _typedefName;

/// Parses a typedef declaration
Binding parseTypedefDeclaration(Pointer<clang.CXCursor> cursor) {
  _binding = null;
  // set name of typedef (used later)
  _typedefName = cursor.spelling();

  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(_typedefdeclarationCursorVisitor,
        clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  return _binding;
}

/// Visitor for extracting binding for a TypedefDeclarations
/// of a [clang.CXCursorKind.CXCursor_TypedefDecl]
///
/// visitor invoked on cursor of type declaration
/// returned by [clang.clang_getTypeDeclaration_wrap]
int _typedefdeclarationCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printExtraVerbose(
        '----typedefdeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_StructDecl:
        _binding = parseStructDeclaration(cursor, name: _typedefName);
        break;
      default:
        printExtraVerbose(
            '----typedefdeclarationCursorVisitor: Not Implemented');
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
