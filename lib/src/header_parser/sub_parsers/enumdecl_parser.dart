import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/print.dart';

import '../includer.dart';
import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// Temporarily holds a enumClass before its returned by [parseEnumDeclaration]
EnumClass _enumClass;

/// Parses a function declaration
EnumClass parseEnumDeclaration(Pointer<clang.CXCursor> cursor) {
  _enumClass = null;

  var name = cursor.spelling();
  if (shouldIncludeEnumClass(name)) {
    printVerbose("Enum: ${cursor.completeStringRepr()}");

    _enumClass = EnumClass(
      name: name,
    );
    _addEnumConstant(cursor);
  }

  return _enumClass;
}

void _addEnumConstant(Pointer<clang.CXCursor> cursor) {
  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
        _enumCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
}

/// Visitor for a function cursor [clang.CXCursorKind.CXCursor_EnumDecl]
///
/// Invoked on every function directly under rootCursor
/// for extracting parameters
int _enumCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printExtraVerbose('--enumCursorVisitor: ${cursor.completeStringRepr()}');
    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_EnumConstantDecl:
        _addEnumConstantToEnumClass(cursor);
        break;
      default:
        print('unknown enum constant');
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

/// Adds the parameter to func in [functiondecl_parser.dart]
void _addEnumConstantToEnumClass(Pointer<clang.CXCursor> cursor) {
  _enumClass.enumConstants.add(
    EnumConstant(
        name: cursor.spelling(),
        value: clang.clang_getEnumConstantDeclValue_wrap(cursor)),
  );
}
