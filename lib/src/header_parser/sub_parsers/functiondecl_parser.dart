// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart' show clang;
import '../includer.dart';
import '../utils.dart';

var _logger = Logger('header_parser:functiondecl_parser.dart');

/// Holds all data required while parsing a function decl.
class _Holder {
  Func func;
  bool structByValueParameter = false;
  bool unimplementedParameterType = false;
  _Holder();
}

/// Temporarily holds a function before its returned by [parseFunctionDeclaration].
///
/// Maintained like a Stack.
List<_Holder> _holders = [];
_Holder get _current => _holders.last;
_Holder _getCurrentAndDispose() => _holders.removeLast();
void _addNewHolder() => _holders.add(_Holder());

/// Parses a function declaration.
Func parseFunctionDeclaration(Pointer<clang_types.CXCursor> cursor) {
  _addNewHolder();
  _current.structByValueParameter = false;
  _current.unimplementedParameterType = false;

  final funcName = cursor.spelling();
  if (shouldIncludeFunc(funcName) && !isSeenFunc(funcName)) {
    _logger.fine('++++ Adding Function: ${cursor.completeStringRepr()}');

    final rt = _getFunctionReturnType(cursor);
    final parameters = _getParameters(cursor);

    //TODO(3): Remove this when support for Structs by value arrives.
    if (rt.broadType == BroadType.Struct || _current.structByValueParameter) {
      _logger.fine(
          '---- Removed Function, reason: struct pass/return by value: ${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', struct pass/return by value not supported.");
      return _getCurrentAndDispose()
          .func; // Returning null so that [addToBindings] function excludes this.
    }

    if (rt.getBaseType().broadType == BroadType.Unimplemented ||
        _current.unimplementedParameterType) {
      _logger.fine(
          '---- Removed Function, reason: unsupported return type or parameter type: ${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', function has unsupported return type or parameter type.");
      return _getCurrentAndDispose()
          .func; // Returning null so that [addToBindings] function excludes this.
    }

    _current.func = Func(
      dartDoc: getCursorDocComment(
        cursor,
        nesting.length + commentPrefix.length,
      ),
      name: config.functionDecl.getPrefixedName(funcName),
      originalName: funcName,
      returnType: rt,
      parameters: parameters,
    );
    addFuncToSeen(funcName, _current.func);
  }

  return _getCurrentAndDispose().func;
}

Type _getFunctionReturnType(Pointer<clang_types.CXCursor> cursor) {
  return cursor.returnType().toCodeGenTypeAndDispose();
}

List<Parameter> _getParameters(Pointer<clang_types.CXCursor> cursor) {
  final parameters = <Parameter>[];

  final totalArgs = clang.clang_Cursor_getNumArguments_wrap(cursor);
  for (var i = 0; i < totalArgs; i++) {
    final paramCursor = clang.clang_Cursor_getArgument_wrap(cursor, i);

    _logger.finer('===== parameter: ${paramCursor.completeStringRepr()}');

    final pt = _getParameterType(paramCursor);
    //TODO(3): Remove this when support for Structs by value arrives.
    if (pt.broadType == BroadType.Struct) {
      _current.structByValueParameter = true;
    } else if (pt.getBaseType().broadType == BroadType.Unimplemented) {
      _current.unimplementedParameterType = true;
    }

    final pn = paramCursor.spelling();

    /// If [pn] is null or empty, its set to `arg$i` by code_generator.
    parameters.add(
      Parameter(
        name: pn,
        type: pt,
      ),
    );
    paramCursor.dispose();
  }

  return parameters;
}

Type _getParameterType(Pointer<clang_types.CXCursor> cursor) {
  return cursor.type().toCodeGenTypeAndDispose();
}
