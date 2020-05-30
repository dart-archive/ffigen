import 'dart:ffi';
import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import '../includer.dart';
import '../clang_bindings/clang_bindings.dart' as clang;
import '../clang_bindings/clang_constants.dart' as clang;
import '../utils.dart';

var _logger = Logger('parser:functiondecl_parser');

/// Temporarily holds a function before its returned by [parseFunctionDeclaration]
Func _func;

/// Parses a function declaration
Func parseFunctionDeclaration(Pointer<clang.CXCursor> cursor) {
  _func = null;

  var name = cursor.spelling();
  if (shouldIncludeFunc(name)) {
    _logger.fine("Function: ${cursor.completeStringRepr()}");

    Type rt = _getFunctionReturnType(cursor);
    var parameters = _getParameters(cursor);

    //TODO: remove this when support for Structs by value arrive
    if (rt.type == BroadType.Struct || parameters == null) {
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
  List<Parameter> parameters = [];

  int totalArgs = clang.clang_Cursor_getNumArguments_wrap(cursor);
  for (var i = 0; i < totalArgs; i++) {
    var paramCursor = clang.clang_Cursor_getArgument_wrap(cursor, i);

    var pt = _getParameterType(paramCursor);
    //TODO: remove this when support for Structs by value arrive
    if (pt.type == BroadType.Struct) {
      return null; //returning null so that [parseFunctionDeclaration] returns null
    }
    var pn = paramCursor.spelling();
    // set name if it is null or not provided
    // TODO: look into extracting name from definition if avaialable
    if (pn == null || pn == '') {
      pn = "arg$i";
    }
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
