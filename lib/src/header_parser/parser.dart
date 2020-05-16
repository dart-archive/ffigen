import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'clang_bindings/clang_bindings.dart' as clang;
import 'clang_bindings/clang_constants.dart' as clang;

import 'utils.dart';

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
      clang.CXTranslationUnit_Flags.CXTranslationUnit_None,
    );

    // TODO: look into printing error details using `clang_parseTranslationUnit2` method
    if (tu == null) {
      throw Exception('Error creating translation Unit');
    }

    print('debug:\n' + getTUDiagnostic(tu));

    var rootCursor = clang.clang_getTranslationUnitCursor_wrap(tu);

    clang.clang_visitChildren_wrap(
      rootCursor,
      Pointer.fromFunction(
          rootCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
      nullptr,
    );

    clang.clang_disposeTranslationUnit(tu);
    clang.clang_disposeIndex(index);
  }
}

int rootCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('debug rootCursorVisitor: ${cursorAsString(cursor)}');
  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_FunctionDecl:
      clang.clang_visitChildren_wrap(
        cursor,
        Pointer.fromFunction(
            functionCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
        nullptr,
      );
      break;
    default:
      print('debug: Not Implemented');
  }

  free(parent);
  free(cursor);
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}

int functionCursorVisitor(Pointer<clang.CXCursor> cursor,
    Pointer<clang.CXCursor> parent, Pointer<Void> clientData) {
  print('  debug functionCursorVisitor: ${cursorAsString(cursor)}');
  switch (clang.clang_getCursorKind_wrap(cursor)) {
    case clang.CXCursorKind.CXCursor_ParmDecl:
      break;
    default:
      print('debug: Not Implemented');
  }
  free(parent);
  free(cursor);
  return clang.CXChildVisitResult.CXChildVisit_Continue;
}

String returnTypeString(Pointer<clang.CXType> type) {
  switch (type.ref.kind) {
    case clang.CXTypeKind.CXType_Int:
      return 'int32';
    case clang.CXTypeKind.CXType_Float:
      return 'float';
    case clang.CXTypeKind.CXType_Double:
      return 'double';
    case clang.CXTypeKind.CXType_Pointer:
      return '*' + returnTypeString(clang.clang_getPointeeType_wrap(type));
    default:
      throw Exception('Unimplemented type: ${type.ref.kind}');
  }
}
