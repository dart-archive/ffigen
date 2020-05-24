import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/print.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'clang_bindings/clang_constants.dart' as clang;
import 'utils.dart';
import './sub_parsers/functiondecl_parser.dart';
import './sub_parsers/structdecl_parser.dart';
import './sub_parsers/typedefdecl_parser.dart';

List<Binding> _bindings;

/// Parses the root cursor and returns the generated bindings
List<Binding> parseRootCursor(Pointer<clang.CXCursor> cursor) {
  _bindings = [];

  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
        _rootCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  return _bindings;
}

/// Visitor for the Root cursor [CXCursorKind.CXCursor_TranslationUnit]
///
/// child visitor invoked on translationUnitCursor
int _rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printExtraVerbose('rootCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_FunctionDecl:
        _addToBindings(parseFunctionDeclaration(cursor));
        break;
      case clang.CXCursorKind.CXCursor_TypedefDecl:
        _addToBindings(parseTypedefDeclaration(cursor));
        break;
      case clang.CXCursorKind.CXCursor_StructDecl:
        _addToBindings(parseStructDeclaration(cursor));
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

/// Adds to binding if not null
void _addToBindings(Binding b) {
  if (b != null) {
    _bindings.add(b);
  }
}
