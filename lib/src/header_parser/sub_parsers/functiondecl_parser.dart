// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.functiondecl_parser');

/// Holds temporary information regarding [Func] while parsing.
class _ParserFunc {
  Func? func;
  bool incompleteStructParameter = false;
  bool unimplementedParameterType = false;
  _ParserFunc();
}

final _stack = Stack<_ParserFunc>();

/// Parses a function declaration.
Func? parseFunctionDeclaration(clang_types.CXCursor cursor) {
  _stack.push(_ParserFunc());

  final funcUsr = cursor.usr();
  final funcName = cursor.spelling();
  if (shouldIncludeFunc(funcUsr, funcName)) {
    _logger.fine('++++ Adding Function: ${cursor.completeStringRepr()}');

    final rt = _getFunctionReturnType(cursor);
    final parameters = _getParameters(cursor, funcName);

    if (clang.clang_Cursor_isFunctionInlined(cursor) != 0) {
      _logger.fine('---- Removed Function, reason: inline function: '
          '${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', inline functions are not supported.");
      // Returning null so that [addToBindings] function excludes this.
      return _stack.pop().func;
    }

    if (rt.isIncompleteCompound || _stack.top.incompleteStructParameter) {
      _logger.fine(
          '---- Removed Function, reason: Incomplete struct pass/return by '
          'value: ${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', Incomplete struct pass/return by "
          'value not supported.');
      // Returning null so that [addToBindings] function excludes this.
      return _stack.pop().func;
    }

    if (rt.baseType is UnimplementedType ||
        _stack.top.unimplementedParameterType) {
      _logger.fine('---- Removed Function, reason: unsupported return type or '
          'parameter type: ${cursor.completeStringRepr()}');
      _logger.warning(
          "Skipped Function '$funcName', function has unsupported return type "
          'or parameter type.');
      // Returning null so that [addToBindings] function excludes this.
      return _stack.pop().func;
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
      exposeSymbolAddress:
          config.functionDecl.shouldIncludeSymbolAddress(funcName),
      exposeFunctionTypedefs:
          config.exposeFunctionTypedefs.shouldInclude(funcName),
      isLeaf: config.leafFunctions.shouldInclude(funcName),
    );
    bindingsIndex.addFuncToSeen(funcUsr, _stack.top.func!);
  } else if (bindingsIndex.isSeenFunc(funcUsr)) {
    _stack.top.func = bindingsIndex.getSeenFunc(funcUsr);
  }

  return _stack.pop().func;
}

Type _getFunctionReturnType(clang_types.CXCursor cursor) {
  return cursor.returnType().toCodeGenType();
}

List<Parameter> _getParameters(clang_types.CXCursor cursor, String funcName) {
  final parameters = <Parameter>[];

  final totalArgs = clang.clang_Cursor_getNumArguments(cursor);
  for (var i = 0; i < totalArgs; i++) {
    final paramCursor = clang.clang_Cursor_getArgument(cursor, i);

    _logger.finer('===== parameter: ${paramCursor.completeStringRepr()}');

    final pt = _getParameterType(paramCursor);
    if (pt.isIncompleteCompound) {
      _stack.top.incompleteStructParameter = true;
    } else if (pt.baseType is UnimplementedType) {
      _logger.finer('Unimplemented type: ${pt.baseType}');
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
  }

  return parameters;
}

Type _getParameterType(clang_types.CXCursor cursor) {
  return cursor.type().toCodeGenType();
}
