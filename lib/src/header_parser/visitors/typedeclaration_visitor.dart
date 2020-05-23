import 'dart:ffi';

import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../data.dart' as data;

/// Visitor for the TypeDeclarations to extract typestring
/// of a [clang.CXType.CXType_Typedef]
///
/// visitor invoked on cursor of type declaration
/// returned by [clang.clang_getTypeDeclaration_wrap]
int typedeclarationCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printVerbose(
        '----typedeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_StructDecl:
        var type = cursor.type();
        data.typeString = type.spelling();
        type.dispose();
        break;
      default:
        printVerbose('----typedeclarationCursorVisitor: Not Implemented');
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
