import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/print.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';
import '../data.dart' as data;

/// Temporarily holds a struc before its returned by [parseStructDeclaration]
Struc struc;

/// Parses a struct declaration
Struc parseStructDeclaration(
  Pointer<clang.CXCursor> cursor, {

  /// Optionally provide name (useful in case struct is inside a typedef)
  String name,
}) {
  if (name == null && cursor.spelling() == '') {
    printExtraVerbose('unnamed structure declaration');
  }
  String structName = name ?? cursor.spelling();
  if (data.config.structFilters != null &&
      data.config.structFilters.shouldInclude(structName)) {
    printVerbose(
        "Structure: name:${structName} ${cursor.completeStringRepr()}");
    // TODO: also parse struct fields
    struc = Struc(name: structName);
  }

  var s = struc;
  struc = null;
  return s;
}
