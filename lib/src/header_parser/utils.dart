// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../strings.dart' as strings;
import 'clang_bindings/clang_bindings.dart' as clang;
import 'data.dart' as data;
import 'type_extractor/extractor.dart';

/// Check [resultCode] of [data.bindings.clang_visitChildren_wrap].
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
  final total = data.bindings.clang_getNumDiagnostics(tu);
  if (total == 0) {
    return;
  }

  logger.warning('Header $header: Total errors/warnings: $total.');
  for (var i = 0; i < total; i++) {
    final diag = data.bindings.clang_getDiagnostic(tu, i);
    final cxstring = data.bindings.clang_formatDiagnostic_wrap(
      diag,
      clang.CXDiagnosticDisplayOptions.CXDiagnostic_DisplaySourceLocation |
          clang.CXDiagnosticDisplayOptions.CXDiagnostic_DisplayColumn |
          clang.CXDiagnosticDisplayOptions.CXDiagnostic_DisplayCategoryName,
    );
    logger.warning('    ' + cxstring.toStringAndDispose());
    data.bindings.clang_disposeDiagnostic(diag);
  }
}

extension CXSourceRangeExt on Pointer<clang.CXSourceRange> {
  void dispose() {
    free(this);
  }
}

extension CXCursorExt on Pointer<clang.CXCursor> {
  /// Returns the kind int from [clang.CXCursorKind].
  int kind() {
    return data.bindings.clang_getCursorKind_wrap(this);
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name).
  String spelling() {
    return data.bindings
        .clang_getCursorSpelling_wrap(this)
        .toStringAndDispose();
  }

  /// Spelling for a [clang.CXCursorKind], useful for debug purposes.
  String kindSpelling() {
    return data.bindings
        .clang_getCursorKindSpelling_wrap(
            data.bindings.clang_getCursorKind_wrap(this))
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
    return data.bindings.clang_getCursorType_wrap(this);
  }

  /// Only valid for [clang.CXCursorKind.CXCursor_FunctionDecl].
  ///
  /// Dispose type using [type.dispose].
  Pointer<clang.CXType> returnType() {
    final t = type();
    final r = data.bindings.clang_getResultType_wrap(t);
    t.dispose();
    return r;
  }

  String sourceFileName() {
    final cxsource = data.bindings.clang_getCursorLocation_wrap(this);
    final cxfilePtr = allocate<Pointer<Void>>();
    final line = allocate<Uint32>();
    final column = allocate<Uint32>();
    final offset = allocate<Uint32>();

    // Puts the values in these pointers.
    data.bindings
        .clang_getFileLocation_wrap(cxsource, cxfilePtr, line, column, offset);
    final s = data.bindings
        .clang_getFileName_wrap(cxfilePtr.value)
        .toStringAndDispose();
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

const commentPrefix = '/// ';
const nesting = '  ';

/// Stores the [clang.CXSourceRange] of the last comment.
Pointer<clang.CXSourceRange> lastCommentRange = nullptr;

/// Returns a cursor's associated comment.
///
/// The given string is wrapped at line width = 80 - [indent]. The [indent] is
/// [commentPrefix.dimensions] by default because a comment starts with
/// [commentPrefix].
String getCursorDocComment(Pointer<clang.CXCursor> cursor,
    [int indent = commentPrefix.length]) {
  String formattedDocComment;
  final currentCommentRange =
      data.bindings.clang_Cursor_getCommentRange_wrap(cursor);

  // See if this comment and the last comment both point to the same source
  // range.
  if (lastCommentRange != nullptr &&
      currentCommentRange != nullptr &&
      data.bindings
              .clang_equalRanges_wrap(lastCommentRange, currentCommentRange) !=
          0) {
    formattedDocComment = null;
  } else {
    switch (data.config.comment) {
      case strings.full:
        formattedDocComment = removeRawCommentMarkups(data.bindings
            .clang_Cursor_getRawCommentText_wrap(cursor)
            .toStringAndDispose());
        break;
      case strings.brief:
        formattedDocComment = _wrapNoNewLineString(
            data.bindings
                .clang_Cursor_getBriefCommentText_wrap(cursor)
                .toStringAndDispose(),
            80 - indent);
        break;
      default:
        formattedDocComment = null;
    }
  }
  lastCommentRange.dispose();
  lastCommentRange = currentCommentRange;
  return formattedDocComment;
}

/// Wraps [string] according to given [lineWidth].
///
/// Wrapping will work properly only when String has no new lines
/// characters(\n).
String _wrapNoNewLineString(String string, int lineWidth) {
  if (string == null || string.isEmpty) {
    return null;
  }
  final sb = StringBuffer();

  final words = string.split(' ');

  sb.write(words[0]);
  int trackLineWidth = words[0].length;
  for (var i = 1; i < words.length; i++) {
    final word = words[i];
    if (trackLineWidth + word.length < lineWidth) {
      sb.write(' ');
      sb.write(word);
      trackLineWidth += word.length + 1;
    } else {
      sb.write('\n');
      sb.write(word);
      trackLineWidth = word.length;
    }
  }
  return sb.toString();
}

/// Removes /*, */ and any *'s in the beginning of a line.
String removeRawCommentMarkups(String string) {
  if (string == null || string.isEmpty) {
    return null;
  }
  final sb = StringBuffer();

  // Remove comment identifiers.
  string = string.replaceAll('/*', '');
  string = string.replaceAll('*/', '');

  // Remove any *'s in the beginning of a every line.
  string.split('\n').forEach((element) {
    element = element.trim().replaceFirst(RegExp(r'\**'), '').trim();
    sb.writeln(element);
  });
  return sb.toString().trim();
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
    return data.bindings.clang_getTypeSpelling_wrap(this).toStringAndDispose();
  }

  /// Returns the typeKind int from [clang.CXTypeKind].
  int kind() {
    return ref.kind;
  }

  String kindSpelling() {
    return data.bindings
        .clang_getTypeKindSpelling_wrap(kind())
        .toStringAndDispose();
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
    final cstring = data.bindings.clang_getCString_wrap(this);
    if (cstring != nullptr) {
      s = Utf8.fromUtf8(cstring.cast());
    }
    return s;
  }

  /// Converts CXString to dart string and disposes CXString.
  String toStringAndDispose() {
    // Note: clang_getCString_wrap returns a const char *, calling free will result in error.
    final s = string();
    data.bindings.clang_disposeString_wrap(this);
    return s;
  }

  void dispose() {
    data.bindings.clang_disposeString_wrap(this);
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
