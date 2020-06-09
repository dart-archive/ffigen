import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../includer.dart';
import '../utils.dart';

var _logger = Logger('parser:functiondecl_parser');

/// Temporarily holds a function before its returned by [parseFunctionDeclaration]
Func _func;

/// Parses a function declaration
Func parseFunctionDeclaration(Pointer<clang.CXCursor> cursor) {
  _func = null;

  var name = cursor.spelling();
  if (shouldIncludeFunc(name)) {
    _logger.fine('++++ Adding Function: ${cursor.completeStringRepr()}');

    var rt = _getFunctionReturnType(cursor);
    var parameters = _getParameters(cursor);

    //TODO: remove this when support for Structs by value arrive
    if (rt.broadType == BroadType.Struct || parameters == null) {
      _logger.fine(
          '---- Removed Function, reason: struct pass/return by value: ${cursor.completeStringRepr()}');
      return null; //returning null so that [addToBindings] function excludes this
    }

    _func = Func(
      dartDoc: clang
          .clang_Cursor_getBriefCommentText_wrap(cursor)
          .toStringAndDispose(),
      name: name,
      returnType: rt,
      parameters: parameters,
    );
  }

  return _func;
}

Type _getFunctionReturnType(Pointer<clang.CXCursor> cursor) {
  return cursor.returnType().toCodeGenTypeAndDispose();
}

List<Parameter> _getParameters(Pointer<clang.CXCursor> cursor) {
  var parameters = <Parameter>[];

  var totalArgs = clang.clang_Cursor_getNumArguments_wrap(cursor);
  for (var i = 0; i < totalArgs; i++) {
    var paramCursor = clang.clang_Cursor_getArgument_wrap(cursor, i);

    _logger.finer('===== parameter: ${paramCursor.completeStringRepr()}');

    var pt = _getParameterType(paramCursor);
    //TODO: remove this when support for Structs by value arrive
    if (pt.broadType == BroadType.Struct) {
      return null; //returning null so that [parseFunctionDeclaration] returns null
    }
    var pn = paramCursor.spelling();

    // if pn is null or ' ', its set to 'arg$i' by code_generator
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

Type _getParameterType(Pointer<clang.CXCursor> cursor) {
  return cursor.type().toCodeGenTypeAndDispose();
}
