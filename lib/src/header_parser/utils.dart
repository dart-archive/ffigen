import 'dart:ffi';
import 'clang_bindings/clang_bindings.dart' as clang;
import 'package:ffi/ffi.dart';

String cxstringToString(Pointer<clang.CXString> cxstring) {
  // Cstring is a const char *, calling free will result in error
  return Utf8.fromUtf8(clang.clang_getCString_wrap(cxstring));
}

String cursorAsString(Pointer<clang.CXCursor> cursor) {
  return '${cursorSpelling(cursor)} kindNum:${clang.clang_getCursorKind_wrap(cursor)} ${cursorKindSpelling(cursor)} typeNum:${clang.clang_getCursorType_wrap(cursor).ref.kind} ${cursorTypeSpelling(cursor)}';
}

String cursorKindSpelling(Pointer<clang.CXCursor> cursor) {
  var cxstring = clang
      .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(cursor));
  var str = cxstringToString(cxstring);
  free(cxstring);
  return str;
}

String cursorSpelling(Pointer<clang.CXCursor> cursor) {
  var cxstring = clang.clang_getCursorSpelling_wrap(cursor);
  var s = cxstringToString(cxstring);
  free(cxstring);
  return s;
}

String cursorTypeSpelling(Pointer<clang.CXCursor> cursor) {
  var cxstring =
      clang.clang_getTypeSpelling_wrap(clang.clang_getCursorType_wrap(cursor));
  var s = cxstringToString(cxstring);
  free(cxstring);
  return s;
}

String getTUDiagnostic(Pointer<clang.CXTranslationUnitImpl> tu) {
  var s = StringBuffer();
  var total = clang.clang_getNumDiagnostics(tu);
  s.write('Total errors/warnings: $total\n');
  for (var i = 0; i < total; i++) {
    var diag = clang.clang_getDiagnostic(tu, i);
    var cxstring = clang.clang_formatDiagnostic_wrap(diag, 0);
    s.write(cxstringToString(cxstring));
    s.write('\n');
  }

  return s.toString();
}
