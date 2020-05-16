import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'clang_bindings/clang_bindings.dart' as clang;

final _bindings = <Binding>[];

class Parser {
  final Config config;

  Parser(this.config) {
    _bindings.clear();
  }

  Library parse() {
    // init clang dynamic library
    // TODO: implement for platforms other than linux
    clang.init(DynamicLibrary.open(config.libclang_dylib_path));

    _parseBindings();

    return Library(bindings: _bindings);
  }

  /// Parses source files and adds generated bindings to [_bindings]
  void _parseBindings() {
    // TODO: implement for more than 1 header in list
    var headerLocation = config.headers[0].path;

    var index = clang.clang_createIndex(0, 0);
    var tu = clang.clang_parseTranslationUnit(
      index,
      Utf8.toUtf8(headerLocation),
      nullptr,
      0,
      nullptr,
      0,
      clang.CXTranslationUnit_None,
    );

    // TODO: look into printing error details using `clang_parseTranslationUnit2` method
    if (tu == null) {
      throw Exception('Error creating translation Unit');
    }

    print('debug:\n' + _getTUDiagnostic(tu));

    var rootCursor = clang.clang_getTranslationUnitCursor_wrap(tu);

    // TODO: set error number for when function is not callable
    clang.clang_visitChildren_wrap(
      rootCursor,
      Pointer.fromFunction(rootCursorVisitor, clang.CXChildVisit_Break),
      nullptr,
    );
  }
}

int rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('debug rootCursorVisitor: ${cursor.asString()}');
  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursor_FunctionDecl:
      clang.clang_visitChildren_wrap(
        cursor,
        Pointer.fromFunction(functionCursorVisitor, clang.CXChildVisit_Break),
        nullptr,
      );
      break;
    default:
      print('debug: Not Implemented');
  }

  free(parent);
  free(cursor);
  return clang.CXChildVisit_Continue;
}

int functionCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('  debug functionCursorVisitor: ${cursor.asString()}');
  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursor_ParmDecl:
      break;
    default:
      print('debug: Not Implemented');
  }
  free(parent);
  free(cursor);
  return clang.CXChildVisit_Continue;
}

String _getTUDiagnostic(Pointer<clang.CXTranslationUnitImpl> tu) {
  var s = StringBuffer();
  var total = clang.clang_getNumDiagnostics(tu);
  s.write('Total errors/warnings: $total\n');
  for (var i = 0; i < total; i++) {
    var diag = clang.clang_getDiagnostic(tu, i);
    var cxstring = clang.clang_formatDiagnostic_wrap(diag, 0);
    s.write(cxstring.asString());
    s.write('\n');
  }

  return s.toString();
}

String returnTypeString(Pointer<clang.CXType> type) {
  switch (type.ref.kind) {
    case clang.CXType_Int:
      return 'int32';
    case clang.CXType_Float:
      return 'float';
    case clang.CXType_Double:
      return 'double';
    case clang.CXType_Pointer:
      return '*' + returnTypeString(clang.clang_getPointeeType_wrap(type));
    default:
      throw Exception('Unimplemented type: ${type.ref.kind}');
  }
}

extension on Pointer<clang.CXString> {
  String asString() {
    // Cstring is a const char *, calling free will result in error
    return Utf8.fromUtf8(clang.clang_getCString_wrap(this));
  }
}

extension on Pointer<clang.CXCursor> {
  String asString() {
    return '${spelling()} kindNum:${clang.clang_getCursorKind_wrap(this)} ${kindSpelling()} typeNum:${clang.clang_getCursorType_wrap(this).ref.kind} ${typeSpelling()}';
  }

  String kindSpelling() {
    var cxstring = clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this));
    var str = cxstring.asString();
    free(cxstring);
    return str;
  }

  String spelling() {
    var cxstring = clang.clang_getCursorSpelling_wrap(this);
    var s = cxstring.asString();
    free(cxstring);
    return s;
  }

  String typeSpelling() {
    var cxstring =
        clang.clang_getTypeSpelling_wrap(clang.clang_getCursorType_wrap(this));
    var s = cxstring.asString();
    free(cxstring);
    return s;
  }
}
