import 'dart:ffi';

import 'package:ffigen/src/header_parser/sub_parsers/structdecl_parser.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Visitor for extracting binding for a TypedefDeclarations
/// of a [clang.CXCursorKind.CXCursor_TypedefDecl]
///
/// visitor invoked on cursor of type declaration
/// returned by [clang.clang_getTypeDeclaration_wrap]
int typedefdeclarationCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printExtraVerbose(
        '----typedefdeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_StructDecl:
        parseStructDeclaration(cursor, name: typeDefNameFromParser);
        break;
      default:
        printExtraVerbose('----typedefdeclarationCursorVisitor: Not Implemented');
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

String typeDefNameFromParser;
