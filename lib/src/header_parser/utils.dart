// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import 'clang_bindings/clang_bindings.dart' as clang;
import 'data.dart';
import 'type_extractor/extractor.dart';

/// Check [resultCode] of [clang.clang_visitChildren_wrap].
///
/// Throws exception if resultCode is not 0.
void visitChildrenResultChecker(int resultCode) {
  if (resultCode != 0) {
    throw Exception(
        'Exception thrown in a dart function called via C, use --verbose to see more details');
  }
}

/// Logs the warnings/errors returned by clang for a translation unit.
void logTuDiagnostics(
  Pointer<clang.CXTranslationUnitImpl> tu,
  Logger logger,
  String header,
) {
  final total = clang.clang_getNumDiagnostics(tu);
  if (total == 0) {
    return;
  }

  logger.warning('Header $header: Total errors/warnings: $total.');
  for (var i = 0; i < total; i++) {
    final diag = clang.clang_getDiagnostic(tu, i);
    final cxstring = clang.clang_formatDiagnostic_wrap(
      diag,
      clang.CXDiagnosticDisplayOptions.CXDiagnostic_DisplaySourceLocation |
          clang.CXDiagnosticDisplayOptions.CXDiagnostic_DisplayColumn |
          clang.CXDiagnosticDisplayOptions.CXDiagnostic_DisplayCategoryName,
    );
    logger.warning('    ' + cxstring.toStringAndDispose());
    clang.clang_disposeDiagnostic(diag);
  }
}

extension CXCursorExt on Pointer<clang.CXCursor> {
  /// Returns the kind int from [clang.CXCursorKind].
  int kind() {
    return clang.clang_getCursorKind_wrap(this);
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name).
  String spelling() {
    return clang.clang_getCursorSpelling_wrap(this).toStringAndDispose();
  }

  /// Spelling for a [clang.CXCursorKind], useful for debug purposes.
  String kindSpelling() {
    return clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this))
        .toStringAndDispose();
  }

  /// for debug: returns [spelling] [kind] [kindSpelling] [type] [typeSpelling].
  String completeStringRepr() {
    final cxtype = type();
    final s =
        '(Cursor) spelling: ${spelling()}, kind: ${kind()}, kindSpelling: ${kindSpelling()}, type: ${cxtype.kind()}, typeSpelling: ${cxtype.spelling()}';
    cxtype.dispose();
    return s;
  }

  /// Dispose type using [type.dispose].
  Pointer<clang.CXType> type() {
    return clang.clang_getCursorType_wrap(this);
  }

  /// Only valid for [clang.CXCursorKind.CXCursor_FunctionDecl].
  ///
  /// Dispose type using [type.dispose].
  Pointer<clang.CXType> returnType() {
    final t = type();
    final r = clang.clang_getResultType_wrap(t);
    t.dispose();
    return r;
  }

  String sourceFileName() {
    final cxsource = clang.clang_getCursorLocation_wrap(this);
    final cxfilePtr = allocate<Pointer<Void>>();
    final line = allocate<Uint32>();
    final column = allocate<Uint32>();
    final offset = allocate<Uint32>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation_wrap(cxsource, cxfilePtr, line, column, offset);
    final s =
        clang.clang_getFileName_wrap(cxfilePtr.value).toStringAndDispose();
    free(cxsource);
    free(cxfilePtr);
    free(line);
    free(column);
    free(offset);
    return s;
  }

  void dispose() {
    free(this);
  }
}

// TODO(13): Improve generated doc comment.
String getCursorDocComment(Pointer<clang.CXCursor> cursor) {
  return config.extractComments
      ? clang.clang_Cursor_getBriefCommentText_wrap(cursor).toStringAndDispose()
      : null;
}

extension CXTypeExt on Pointer<clang.CXType> {
  /// Get code_gen [Type] representation of [clang.CXType].
  Type toCodeGenType() {
    return getCodeGenType(this);
  }

  /// Get code_gen [Type] representation of [clang.CXType] and dispose the type.
  Type toCodeGenTypeAndDispose() {
    final t = getCodeGenType(this);
    dispose();
    return t;
  }

  /// Spelling for a [clang.CXTypeKind], useful for debug purposes.
  String spelling() {
    return clang.clang_getTypeSpelling_wrap(this).toStringAndDispose();
  }

  /// Returns the typeKind int from [clang.CXTypeKind].
  int kind() {
    return ref.kind;
  }

  String kindSpelling() {
    return clang.clang_getTypeKindSpelling_wrap(kind()).toStringAndDispose();
  }

  /// For debugging: returns [spelling] [kind] [kindSpelling].
  String completeStringRepr() {
    final s =
        '(Type) spelling: ${spelling()}, kind: ${kind()}, kindSpelling: ${kindSpelling()}';
    return s;
  }

  void dispose() {
    free(this);
  }
}

extension CXStringExt on Pointer<clang.CXString> {
  /// Convert CXString to a Dart string
  ///
  /// Make sure to dispose CXstring using dispose method, or use the
  /// [toStringAndDispose] method.
  String string() {
    String s;
    final cstring = clang.clang_getCString_wrap(this);
    if (cstring != nullptr) {
      s = Utf8.fromUtf8(cstring.cast());
    }
    return s;
  }

  /// Converts CXString to dart string and disposes CXString.
  String toStringAndDispose() {
    // Note: clang_getCString_wrap returns a const char *, calling free will result in error.
    final s = string();
    clang.clang_disposeString_wrap(this);
    return s;
  }

  void dispose() {
    clang.clang_disposeString_wrap(this);
  }
}

/// Converts a [List<String>] to [Pointer<Pointer<Utf8>>].
Pointer<Pointer<Utf8>> createDynamicStringArray(List<String> list) {
  final nativeCmdArgs = allocate<Pointer<Utf8>>(count: list.length);

  for (var i = 0; i < list.length; i++) {
    nativeCmdArgs[i] = Utf8.toUtf8(list[i]);
  }

  return nativeCmdArgs;
}

extension DynamicCStringArray on Pointer<Pointer<Utf8>> {
  // Properly disposes a Pointer<Pointer<Utf8>, ensure that sure length is correct.
  void dispose(int length) {
    for (var i = 0; i < length; i++) {
      free(this[i]);
    }
    free(this);
  }
}
