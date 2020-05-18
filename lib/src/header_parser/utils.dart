import 'dart:ffi';
import 'cxtypekindmap.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'clang_bindings/clang_constants.dart' as clang;
import 'package:ffi/ffi.dart';

import 'package:ffigen/src/code_generator.dart';
import 'data.dart' as data;

/// Check resultCode of [clang.clang_visitChildren_wrap]
/// Throws exception if resultCode is not 0
void visitChildrenResultChecker(int resultCode) {
  if (resultCode != 0) {
    throw Exception('Exception thrown in a dart function called via C');
  }
}

String getTUDiagnostic(Pointer<clang.CXTranslationUnitImpl> tu) {
  var s = StringBuffer();
  var total = clang.clang_getNumDiagnostics(tu);
  s.write('C header: Total errors/warnings : $total\n');
  for (var i = 0; i < total; i++) {
    var diag = clang.clang_getDiagnostic(tu, i);
    var cxstring = clang.clang_formatDiagnostic_wrap(diag, 0);
    s.write(cxstring.toDartString());
    s.write('\n');
  }

  return s.toString();
}

extension CXCursorExt on Pointer<clang.CXCursor> {
  /// returns the kind int from [clang.CXCursorKind]
  int kind() {
    return clang.clang_getCursorKind_wrap(this);
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name)
  String spelling() {
    var cxstring = clang.clang_getCursorSpelling_wrap(this);
    var s = cxstring.toDartString();
    free(cxstring);
    return s;
  }

  /// spelling for a [clang.CXCursorKind] useful for debug purposes
  String kindSpelling() {
    var cxstring = clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this));
    var str = cxstring.toDartString();
    free(cxstring);
    return str;
  }

  /// for debug: returns [spelling] [kind] [kindSpelling] [type] [typeSpelling]
  String completeStringRepr() {
    return 'spelling: ${this.spelling()}, kind: ${this.kind()}, kindSpelling: ${this.kindSpelling()}, type: ${this.type().kind()}, typeSpelling: ${this.type().spelling()}';
  }

  Pointer<clang.CXType> type() {
    return clang.clang_getCursorType_wrap(this);
  }

  /// Only valid for [clang.CXCursorKind.CXCursor_FunctionDecl]
  Pointer<clang.CXType> returnType() {
    return clang.clang_getResultType_wrap(this.type());
  }
}

extension CXTypeExt on Pointer<clang.CXType> {
  /// Get code_gen [Type] representation of [clang.CXType]
  Type codeGenType() {
    return Type(_getCodeGenTypeString(this));
  }

  /// spelling for a [clang.CXTypeKind] useful for debug purposes
  String spelling() {
    var cxstring = clang.clang_getTypeSpelling_wrap(this);
    var s = cxstring.toDartString();
    free(cxstring);
    return s;
  }

  /// returns the typeKind int from [clang.CXTypeKind]
  int kind() {
    return this.ref.kind;
  }
}

extension CXStringExt on Pointer<clang.CXString> {
  String toDartString() {
    // Note: clang_getCString_wrap returns a const char *, calling free will result in error
    return Utf8.fromUtf8(clang.clang_getCString_wrap(this));
  }
}

/// converts cxtype to a typestring code_generator can accept
String _getCodeGenTypeString(Pointer<clang.CXType> cxtype) {
  int kind = cxtype.kind();

  if (kind == clang.CXTypeKind.CXType_Pointer) {
    return '*' + _getCodeGenTypeString(clang.clang_getPointeeType_wrap(cxtype));
  } else if (cxTypeKindMap.containsKey(kind)) {
    return cxTypeKindMap[kind];
  } else {
    throw Exception(
        'Type (type: ${cxtype.kind()}, speling: ${cxtype.spelling()}) not implemented');
  }
}
