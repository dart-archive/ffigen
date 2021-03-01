// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';

import 'clang_bindings/clang_bindings.dart' as clang_types;
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
  Pointer<clang_types.CXTranslationUnitImpl> tu,
  Logger logger,
  String header,
) {
  final total = clang.clang_getNumDiagnostics(tu);
  if (total == 0) {
    return;
  }

  logger.severe('Header $header: Total errors/warnings: $total.');
  for (var i = 0; i < total; i++) {
    final diag = clang.clang_getDiagnostic(tu, i);
    final cxstring = clang.clang_formatDiagnostic_wrap(
      diag,
      clang_types
              .CXDiagnosticDisplayOptions.CXDiagnostic_DisplaySourceLocation |
          clang_types.CXDiagnosticDisplayOptions.CXDiagnostic_DisplayColumn |
          clang_types
              .CXDiagnosticDisplayOptions.CXDiagnostic_DisplayCategoryName,
    );
    logger.severe('    ' + cxstring.toStringAndDispose());
    clang.clang_disposeDiagnostic(diag);
  }
}

extension CXSourceRangeExt on Pointer<clang_types.CXSourceRange> {
  void dispose() {
    free(this);
  }
}

extension CXCursorExt on Pointer<clang_types.CXCursor> {
  String usr() {
    return clang.clang_getCursorUSR_wrap(this).toStringAndDispose();
  }

  /// Returns the kind int from [clang_types.CXCursorKind].
  int kind() {
    return clang.clang_getCursorKind_wrap(this);
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name).
  String spelling() {
    return clang.clang_getCursorSpelling_wrap(this).toStringAndDispose();
  }

  /// Spelling for a [clang_types.CXCursorKind], useful for debug purposes.
  String kindSpelling() {
    return clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this))
        .toStringAndDispose();
  }

  /// for debug: returns [spelling] [kind] [kindSpelling] [type] [typeSpelling].
  String completeStringRepr() {
    final cxtype = type();
    final s =
        '(Cursor) spelling: ${spelling()}, kind: ${kind()}, kindSpelling: ${kindSpelling()}, type: ${cxtype.kind()}, typeSpelling: ${cxtype.spelling()}, usr: ${usr()}';
    cxtype.dispose();
    return s;
  }

  /// Dispose type using [type.dispose].
  Pointer<clang_types.CXType> type() {
    return clang.clang_getCursorType_wrap(this);
  }

  /// Only valid for [clang.CXCursorKind.CXCursor_FunctionDecl].
  ///
  /// Dispose type using [type.dispose].
  Pointer<clang_types.CXType> returnType() {
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

const commentPrefix = '/// ';
const nesting = '  ';

/// Stores the [clang_types.CXSourceRange] of the last comment.
Pointer<clang_types.CXSourceRange> lastCommentRange = nullptr;

/// Returns a cursor's associated comment.
///
/// The given string is wrapped at line width = 80 - [indent]. The [indent] is
/// [commentPrefix.dimensions] by default because a comment starts with
/// [commentPrefix].
String? getCursorDocComment(Pointer<clang_types.CXCursor> cursor,
    [int indent = commentPrefix.length]) {
  String? formattedDocComment;
  final currentCommentRange = clang.clang_Cursor_getCommentRange_wrap(cursor);

  // See if this comment and the last comment both point to the same source
  // range.
  if (lastCommentRange != nullptr &&
      currentCommentRange != nullptr &&
      clang.clang_equalRanges_wrap(lastCommentRange, currentCommentRange) !=
          0) {
    formattedDocComment = null;
  } else {
    switch (config.commentType.length) {
      case CommentLength.full:
        formattedDocComment = removeRawCommentMarkups(clang
            .clang_Cursor_getRawCommentText_wrap(cursor)
            .toStringAndDispose());
        break;
      case CommentLength.brief:
        formattedDocComment = _wrapNoNewLineString(
            clang
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
String? _wrapNoNewLineString(String? string, int lineWidth) {
  if (string == null || string.isEmpty) {
    return null;
  }
  final sb = StringBuffer();

  final words = string.split(' ');

  sb.write(words[0]);
  var trackLineWidth = words[0].length;
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
String? removeRawCommentMarkups(String? string) {
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

extension CXTypeExt on Pointer<clang_types.CXType> {
  /// Get code_gen [Type] representation of [clang_types.CXType].
  Type toCodeGenType() {
    return getCodeGenType(this);
  }

  /// Get code_gen [Type] representation of [clang_types.CXType] and dispose the type.
  Type toCodeGenTypeAndDispose() {
    final t = getCodeGenType(this);
    dispose();
    return t;
  }

  /// Spelling for a [clang_types.CXTypeKind], useful for debug purposes.
  String spelling() {
    return clang.clang_getTypeSpelling_wrap(this).toStringAndDispose();
  }

  /// Returns the typeKind int from [clang_types.CXTypeKind].
  int? kind() {
    return ref.kind;
  }

  String kindSpelling() {
    return clang.clang_getTypeKindSpelling_wrap(kind()!).toStringAndDispose();
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

extension CXStringExt on Pointer<clang_types.CXString> {
  /// Convert CXString to a Dart string
  ///
  /// Make sure to dispose CXstring using dispose method, or use the
  /// [toStringAndDispose] method.
  String string() {
    final cstring = clang.clang_getCString_wrap(this);
    if (cstring != nullptr) {
      return Utf8.fromUtf8(cstring.cast());
    } else {
      return '';
    }
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

class Stack<T> {
  final _stack = <T>[];

  T get top => _stack.last;
  T pop() => _stack.removeLast();
  void push(T item) => _stack.add(item);
}

class IncrementalNamer {
  final _incrementedStringCounters = <String, int>{};

  /// Appends `_<int>` to base. <int> is incremented on every call.
  String name(String base) {
    var i = _incrementedStringCounters[base] ?? 0;
    i++;
    _incrementedStringCounters[base] = i;
    return '${base}_$i';
  }
}

class Macro {
  final String usr;
  final String? originalName;

  Macro(this.usr, this.originalName);
}

/// Tracks if a binding is 'seen' or not.
class BindingsIndex {
  // Tracks if bindings are already seen, Map key is USR obtained from libclang.
  final Map<String, Struc> _structs = {};
  final Map<String, Func> _functions = {};
  final Map<String, EnumClass> _enumClass = {};
  final Map<String, Constant> _unnamedEnumConstants = {};
  final Map<String, String> _macros = {};
  // Stores only named typedefC used in NativeFunc.
  final Map<String, Typedef> _functionTypedefs = {};

  bool isSeenStruct(String usr) {
    return _structs.containsKey(usr);
  }

  void addStructToSeen(String usr, Struc struc) {
    _structs[usr] = struc;
  }

  Struc? getSeenStruct(String usr) {
    return _structs[usr];
  }

  bool isSeenFunc(String usr) {
    return _functions.containsKey(usr);
  }

  void addFuncToSeen(String usr, Func func) {
    _functions[usr] = func;
  }

  Func? getSeenFunc(String usr) {
    return _functions[usr];
  }

  bool isSeenEnumClass(String usr) {
    return _enumClass.containsKey(usr);
  }

  void addEnumClassToSeen(String usr, EnumClass enumClass) {
    _enumClass[usr] = enumClass;
  }

  EnumClass? getSeenEnumClass(String usr) {
    return _enumClass[usr];
  }

  bool isSeenUnnamedEnumConstant(String usr) {
    return _unnamedEnumConstants.containsKey(usr);
  }

  void addUnnamedEnumConstantToSeen(String usr, Constant enumConstant) {
    _unnamedEnumConstants[usr] = enumConstant;
  }

  Constant? getSeenUnnamedEnumConstant(String usr) {
    return _unnamedEnumConstants[usr];
  }

  bool isSeenMacro(String usr) {
    return _macros.containsKey(usr);
  }

  void addMacroToSeen(String usr, String macro) {
    _macros[usr] = macro;
  }

  String? getSeenMacro(String usr) {
    return _macros[usr];
  }

  bool isSeenFunctionTypedef(String originalName) {
    return _functionTypedefs.containsKey(originalName);
  }

  void addFunctionTypedefToSeen(String originalName, Typedef t) {
    _functionTypedefs[originalName] = t;
  }

  Typedef? getSeenFunctionTypedef(String originalName) {
    return _functionTypedefs[originalName];
  }
}
