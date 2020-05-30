/// Extracts code_gen Type from type
import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../type_extractor/cxtypekindmap.dart';
import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../root_parser.dart';
import '../includer.dart';

var _logger = Logger('parser:extractor');

/// converts cxtype to a typestring code_generator can accept
Type getCodeGenType(Pointer<clang.CXType> cxtype, {String parentName}) {
  _logger.fine('...getCodeGenType ${cxtype.completeStringRepr()}');
  int kind = cxtype.kind();

  switch (kind) {
    case clang.CXTypeKind.CXType_Pointer:
      var pt = clang.clang_getPointeeType_wrap(cxtype);
      var s = getCodeGenType(pt, parentName: parentName);
      pt.dispose();
      return Type(type: BroadType.Pointer, child: s);
    case clang.CXTypeKind.CXType_Typedef:
      var ct = clang.clang_getCanonicalType_wrap(cxtype);
      var s = getCodeGenType(ct, parentName: parentName ?? cxtype.spelling());
      ct.dispose();
      return s;
    case clang.CXTypeKind.CXType_Elaborated:
      var et = clang.clang_Type_getNamedType_wrap(cxtype);
      var s = getCodeGenType(et, parentName: parentName);
      et.dispose();
      return s;
    case clang.CXTypeKind.CXType_Record:
      return _extractfromRecord(cxtype);
    case clang.CXTypeKind.CXType_Enum:
      return Type(
        type: BroadType.NativeType,
        nativeType: SupportedNativeType.Int32,
      );
    case clang.CXTypeKind.CXType_FunctionProto:
      return _extractFromFunctionProto(cxtype, parentName);
    default:
      if (cxTypeKindToSupportedNativeTypes.containsKey(kind)) {
        return Type(
          type: BroadType.NativeType,
          nativeType: cxTypeKindToSupportedNativeTypes[kind],
        );
      } else if (cxTypeKindToFfiUtilType.containsKey(kind)) {
        return Type(
          type: BroadType.FfiUtilType,
          ffiUtilType: cxTypeKindToFfiUtilType[kind],
        );
      } else {
        throw Exception('Type not implemented, ${cxtype.completeStringRepr()}');
      }
  }
}

Type _extractfromRecord(Pointer<clang.CXType> cxtype) {
  Type type;

  var cursor = clang.clang_getTypeDeclaration_wrap(cxtype);
  _logger.fine('----_extractfromRecord: ${cursor.completeStringRepr()}');

  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_StructDecl:
      type = Type(type: BroadType.Struct);

      var cxtype = cursor.type();
      type.structName = cursor.spelling();
      if (type.structName == '') {
        // incase of anonymous structs defined inside a typedef
        type.structName = cxtype.spelling();
      }
      cxtype.dispose();
      break;
    default:
      _logger.fine('----typedeclarationCursorVisitor: Not Implemented');
  }
  cursor.dispose();
  return type;
}

Type _extractFromFunctionProto(
    Pointer<clang.CXType> cxtype, String parentName) {
  String name = parentName;

  // set a name for typedefc incase it was null or empty
  if (name == null || name == '') {
    name = _getNextUniqueString('_typedefC_noname');
  }

  if (shouldIncludeTypedefC(name)) {
    var typedefC = TypedefC(
      name: name,
      returnType:
          clang.clang_getResultType_wrap(cxtype).toCodeGenTypeAndDispose(),
    );
    int totalArgs = clang.clang_getNumArgTypes_wrap(cxtype);
    for (var i = 0; i < totalArgs; i++) {
      var t = clang.clang_getArgType_wrap(cxtype, i);
      typedefC.parameters.add(
        Parameter(name: '', type: t.toCodeGenTypeAndDispose()),
      );
    }
    addToBindings(typedefC);
  }
  return Type(type: BroadType.NativeFunction, nativeFuncName: name);
}

// generates unique string
int _i = 0;
String _getNextUniqueString(String prefix) {
  _i++;
  return "${prefix}_$_i";
}
