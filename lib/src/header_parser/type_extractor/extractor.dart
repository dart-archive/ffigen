/// Extracts code_gen Type from type
import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/print.dart';

import '../type_extractor/cxtypekindmap.dart';
import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

/// converts cxtype to a typestring code_generator can accept

Type getCodeGenType(Pointer<clang.CXType> cxtype) {
  return Type(_getCodeGenTypeString(cxtype));
}

// temporarily stores typestring before returning it
String _typeString;

String _getCodeGenTypeString(Pointer<clang.CXType> cxtype) {
  int kind = cxtype.kind();

  switch (kind) {
    case clang.CXTypeKind.CXType_Pointer:
      var pt = clang.clang_getPointeeType_wrap(cxtype);
      var ct = _getCodeGenTypeString(pt);
      pt.dispose();
      return '*' + ct;
    case clang.CXTypeKind.CXType_Typedef:
      //TODO: replace with actual type
      return _extractfromTypedef(cxtype);
    default:
      if (cxTypeKindMap.containsKey(kind)) {
        return cxTypeKindMap[kind];
      } else {
        throw Exception(
            'Type not implemented, cxtypekind: ${cxtype.kind()}, speling: ${cxtype.spelling()}');
      }
  }
}

String _extractfromTypedef(Pointer<clang.CXType> cxtype) {
  var cursor = clang.clang_getTypeDeclaration_wrap(cxtype);

  /// stores result in [_typestring]
  int resultCode = clang.clang_visitChildren_wrap(
    cursor,
    Pointer.fromFunction(
      _typedeclarationCursorVisitor,
      clang.CXChildVisitResult.CXChildVisit_Break,
    ),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);
  cursor.dispose();
  return _typeString;
}

/// Visitor for the TypeDeclarations to extract typestring
/// of a [clang.CXType.CXType_Typedef]
///
/// visitor invoked on cursor of type declaration
/// returned by [clang.clang_getTypeDeclaration_wrap]
int _typedeclarationCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  try {
    printVerbose(
        '----typedeclarationCursorVisitor: ${cursor.completeStringRepr()}');

    switch (clang.clang_getCursorKind_wrap(cursor)) {
      case clang.CXCursorKind.CXCursor_StructDecl:
        var type = cursor.type();
        _typeString = type.spelling();
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
