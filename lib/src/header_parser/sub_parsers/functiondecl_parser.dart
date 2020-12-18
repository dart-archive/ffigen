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

final _logger = Logger('ffigen.header_parser.functiondecl_parser');

/// Holds temporary information regarding [Func] while parsing.
class _ParserFunc {
  Func? func;
  bool structByValueParameter = false;
  bool unimplementedParameterType = false;
  _ParserFunc();
}

final _stack = Stack<_ParserFunc>();

/// Parses a function declaration.
Func? parseFunctionDeclaration(Pointer<clang_types.CXCursor> cursor) {
  _stack.push(_ParserFunc());
  _stack.top.structByValueParameter = false;
  _stack.top.unimplementedParameterType = false;

  final funcUsr = cursor.usr();
  final funcName = cursor.spelling();
  if (shouldIncludeFunc(funcUsr, funcName)) {
    _logger.fine('++++ Adding Function: ${cursor.completeStringRepr()}');

    final rt = _getFunctionReturnType(cursor);
    final parameters = _getParameters(cursor, funcName);

    //TODO(3): Remove this when support for Structs by value arrives.
    if (rt.broadType == BroadType.Struct || _stack.top.structByValueParameter) {
      _logger.fine(
          '---- Removed Function, reason: struct pass/return by value: ${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', struct pass/return by value not supported.");
      return _stack
          .pop()
          .func; // Returning null so that [addToBindings] function excludes this.
    }

    if (rt.getBaseType().broadType == BroadType.Unimplemented ||
        _stack.top.unimplementedParameterType) {
      _logger.fine(
          '---- Removed Function, reason: unsupported return type or parameter type: ${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', function has unsupported return type or parameter type.");
      return _stack
          .pop()
          .func; // Returning null so that [addToBindings] function excludes this.
    }

    _stack.top.func = Func(
      dartDoc: getCursorDocComment(
        cursor,
        nesting.length + commentPrefix.length,
      ),
      usr: funcUsr,
      name: config.functionDecl.renameUsingConfig(funcName),
      originalName: funcName,
      returnType: rt,
      parameters: parameters,
    );
    bindingsIndex.addFuncToSeen(funcUsr, _stack.top.func!);
  } else if (bindingsIndex.isSeenFunc(funcUsr)) {
    _stack.top.func = bindingsIndex.getSeenFunc(funcUsr);
  }

  return _stack.pop().func;
}

Type _getFunctionReturnType(Pointer<clang_types.CXCursor> cursor) {
  return cursor.returnType().toCodeGenTypeAndDispose();
}

List<Parameter> _getParameters(
    Pointer<clang_types.CXCursor> cursor, String funcName) {
  final parameters = <Parameter>[];

  final totalArgs = clang.clang_Cursor_getNumArguments_wrap(cursor);
  for (var i = 0; i < totalArgs; i++) {
    final paramCursor = clang.clang_Cursor_getArgument_wrap(cursor, i);

    _logger.finer('===== parameter: ${paramCursor.completeStringRepr()}');

    final pt = _getParameterType(paramCursor);
    //TODO(3): Remove this when support for Structs by value arrives.
    if (pt.broadType == BroadType.Struct) {
      _stack.top.structByValueParameter = true;
    } else if (pt.getBaseType().broadType == BroadType.Unimplemented) {
      _stack.top.unimplementedParameterType = true;
    }

    final pn = paramCursor.spelling();

    /// If [pn] is null or empty, its set to `arg$i` by code_generator.
    parameters.add(
      Parameter(
        originalName: pn,
        name: config.functionDecl.renameMemberUsingConfig(funcName, pn),
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
