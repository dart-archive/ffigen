import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'clang_bindings/clang_constants.dart' as clang;
import 'utils.dart';
import 'visitors/root_visitor.dart';

/// Main entrypoint for header_parser
Library parse(Config conf) {
  initParser(conf);

  parseAndStoreBindings();

  return Library(bindings: bindings);
}

// ===================================================================================

final bindings = <Binding>[];
Config config;

/// initialises parser, clears any previous values
void initParser(Config c) {
  config = c;
  bindings.clear();

  // TODO: implement for platforms other than linux
  // init clang dynamic library
  clang.init(DynamicLibrary.open(config.libclang_dylib_path));
}

/// Parses source files and adds generated bindings to [bindings]
void parseAndStoreBindings() {
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
