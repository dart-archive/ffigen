import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'clang_bindings/clang_constants.dart' as clang;
import 'utils.dart';
import 'visitors/root_visitor.dart';

// Holds all global data
import 'data.dart' as data;

/// Main entrypoint for header_parser
Library parse(Config conf) {
  initParser(conf);

  var bindings = parseAndGenerateBindings();

  return Library(bindings: bindings);
}

// ===================================================================================
//           BELOW FUNCTIONS ARE MEANT FOR INTERNAL USE AND TESTING
// ===================================================================================

/// initialises parser, clears any previous values
void initParser(Config c) {
  data.config = c;
  data.bindings = <Binding>[];

  // TODO: implement for platforms other than linux
  clang.init(DynamicLibrary.open(data.config.libclang_dylib_path));
}

/// Parses source files and adds generated bindings to [bindings]
List<Binding> parseAndGenerateBindings() {
  // TODO: implement for more than 1 header in list
  var headerLocation = data.config.headers[0].path;

  var index = clang.clang_createIndex(0, 0);

  Pointer<Pointer<Utf8>> clangCmdArgs =
      createDynamicStringArray(data.config.compilerOpts);

  var tu = clang.clang_parseTranslationUnit(
    index,
    Utf8.toUtf8(headerLocation),
    clangCmdArgs,
    data.config.compilerOpts.length,
    nullptr,
    0,
    clang.CXTranslationUnit_Flags.CXTranslationUnit_None,
  );

  clangCmdArgs.dispose(data.config.compilerOpts.length);

  // TODO: look into printing error details using `clang_parseTranslationUnit2` method
  if (tu == null) {
    throw Exception('Error creating translation Unit');
  }

  print('debug:\n' + getTUDiagnostic(tu));
  var rootCursor = clang.clang_getTranslationUnitCursor_wrap(tu);

  int resultCode = clang.clang_visitChildren_wrap(
    rootCursor,
    Pointer.fromFunction(
        rootCursorVisitor, clang.CXChildVisitResult.CXChildVisit_Break),
    nullptr,
  );

  visitChildrenResultChecker(resultCode);

  // cleanup
  rootCursor.dispose();
  clang.clang_disposeTranslationUnit(tu);
  clang.clang_disposeIndex(index);

  return data.bindings;
}
