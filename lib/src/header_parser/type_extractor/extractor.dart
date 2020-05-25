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

String _getCodeGenTypeString(Pointer<clang.CXType> cxtype) {
  printVerbose('...getCodeGenType ${cxtype.completeStringRepr()}');
  int kind = cxtype.kind();

  switch (kind) {
    case clang.CXTypeKind.CXType_Pointer:
      var pt = clang.clang_getPointeeType_wrap(cxtype);
      var s = _getCodeGenTypeString(pt);
      pt.dispose();
      return '*' + s;
    case clang.CXTypeKind.CXType_Typedef:
      var ct = clang.clang_getCanonicalType_wrap(cxtype);
      var s = _getCodeGenTypeString(ct);
      ct.dispose();
      return s;
    case clang.CXTypeKind.CXType_Elaborated:
      var et = clang.clang_Type_getNamedType_wrap(cxtype);
      var s = _getCodeGenTypeString(et);
      et.dispose();
      return s;
    case clang.CXTypeKind.CXType_Record:
      return _extractfromRecord(cxtype);
    case clang.CXTypeKind.CXType_Enum:
      return 'int32';
    default:
      if (cxTypeKindMap.containsKey(kind)) {
        return cxTypeKindMap[kind];
      } else {
        throw Exception('Type not implemented, ${cxtype.completeStringRepr()}');
      }
  }
}

String _extractfromRecord(Pointer<clang.CXType> cxtype) {
  // default for detecting if not parsed correctly
  String _typeString = 'UNPARSABLECXTYPERECORD';
  var cursor = clang.clang_getTypeDeclaration_wrap(cxtype);
  printVerbose('----_extractfromRecord: ${cursor.completeStringRepr()}');

  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_StructDecl:
      var type = cursor.type();
      _typeString = cursor.spelling();
      if (_typeString == '') { // incase of anonymous structs defined inside a typedef 
        _typeString = type.spelling();
      }
      type.dispose();
      break;
    default:
      printVerbose('----typedeclarationCursorVisitor: Not Implemented');
  }
  cursor.dispose();
  return _typeString;
}
