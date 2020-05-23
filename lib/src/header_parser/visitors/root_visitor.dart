import 'dart:ffi';

import 'package:ffigen/src/header_parser/sub_parsers/functiondecl_parser.dart';
import '../sub_parsers/typedefdecl_parser.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Visitor for the Root cursor [CXCursorKind.CXCursor_TranslationUnit]
///
/// child visitor invoked on translationUnitCursor
int rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printExtraVerbose('rootCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_FunctionDecl:
        parseFunctionDeclaration(cursor);
        break;
      case clang.CXCursorKind.CXCursor_TypedefDecl:
        parseTypedefDeclaration(cursor);
        break;
      default:
        printExtraVerbose('rootCursorVisitor: CursorKind not implemented');
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
