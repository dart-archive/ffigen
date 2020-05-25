import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'clang_bindings/clang_constants.dart' as clang;
import 'type_extractor/extractor.dart';

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
    s.write(cxstring.toStringAndDispose());
    s.write('\n');
    clang.clang_disposeDiagnostic(diag);
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
    return clang.clang_getCursorSpelling_wrap(this).toStringAndDispose();
  }

  /// spelling for a [clang.CXCursorKind] useful for debug purposes
  String kindSpelling() {
    return clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this))
        .toStringAndDispose();
  }

  /// for debug: returns [spelling] [kind] [kindSpelling] [type] [typeSpelling]
  String completeStringRepr() {
    var cxtype = this.type();
    String s =
        '(Cursor) spelling: ${this.spelling()}, kind: ${this.kind()}, kindSpelling: ${this.kindSpelling()}, type: ${cxtype.kind()}, typeSpelling: ${cxtype.spelling()}';
    cxtype.dispose();
    return s;
  }

  /// Dispose type using [type.dispose]
  Pointer<clang.CXType> type() {
    return clang.clang_getCursorType_wrap(this);
  }

  /// Only valid for [clang.CXCursorKind.CXCursor_FunctionDecl]
  ///
  /// Dispose type using [type.dispose]
  Pointer<clang.CXType> returnType() {
    var t = this.type();
    var r = clang.clang_getResultType_wrap(t);
    t.dispose();
    return r;
  }

  void dispose() {
    free(this);
  }
}

extension CXTypeExt on Pointer<clang.CXType> {
  /// Get code_gen [Type] representation of [clang.CXType]
  Type toCodeGenType() {
    return getCodeGenType(this);
  }

  /// Get code_gen [Type] representation of [clang.CXType] and dispose the type
  Type toCodeGenTypeAndDispose() {
    var t = getCodeGenType(this);
    this.dispose();
    return t;
  }

  /// spelling for a [clang.CXTypeKind] useful for debug purposes
  String spelling() {
    return clang.clang_getTypeSpelling_wrap(this).toStringAndDispose();
  }

  /// returns the typeKind int from [clang.CXTypeKind]
  int kind() {
    return this.ref.kind;
  }

  String kindSpelling() {
    return clang
        .clang_getTypeKindSpelling_wrap(this.kind())
        .toStringAndDispose();
  }

  /// for debug: returns [spelling] [kind] [kindSpelling]
  String completeStringRepr() {
    String s =
        '(Type) spelling: ${this.spelling()}, kind: ${this.kind()}, kindSpelling: ${this.kindSpelling()}';
    return s;
  }

  void dispose() {
    free(this);
  }
}

extension CXStringExt on Pointer<clang.CXString> {
  /// Dispose CXstring using dispose
  String string() {
    return Utf8.fromUtf8(clang.clang_getCString_wrap(this));
  }

  /// Converts CXString to dart string and disposes CXString
  String toStringAndDispose() {
    // Note: clang_getCString_wrap returns a const char *, calling free will result in error
    var s = Utf8.fromUtf8(clang.clang_getCString_wrap(this));
    clang.clang_disposeString_wrap(this);
    return s;
  }

  void dispose() {
    clang.clang_disposeString_wrap(this);
  }
}

// Converts a List<String> to Pointer<Pointer<Utf8>>
Pointer<Pointer<Utf8>> createDynamicStringArray(List<String> list) {
  Pointer<Pointer<Utf8>> nativeCmdArgs =
      allocate<Pointer<Utf8>>(count: list.length);

  for (var i = 0; i < list.length; i++) {
    nativeCmdArgs[i] = Utf8.toUtf8(list[i]);
  }

  return nativeCmdArgs;
}

extension DynamicCStringArray on Pointer<Pointer<Utf8>> {
  // properly disposes a Pointer<Pointer<Utf8>, ensure that sure length is correct
  void dispose(int length) {
    for (var i = 0; i < length; i++) {
      free(this[i]);
    }
    free(this);
  }
}
