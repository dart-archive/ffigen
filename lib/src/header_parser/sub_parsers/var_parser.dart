// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/includer.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.var_parser');

/// Parses a global variable
Global? parseVarDeclaration(clang_types.CXCursor cursor) {
  final name = cursor.spelling();
  final usr = cursor.usr();
  if (bindingsIndex.isSeenGlobalVar(usr)) {
    return bindingsIndex.getSeenGlobalVar(usr);
  }
  if (!shouldIncludeGlobalVar(usr, name)) {
    return null;
  }

  _logger.fine('++++ Adding Global: ${cursor.completeStringRepr()}');

  final type = cursor.type().toCodeGenType();
  if (type.baseType is UnimplementedType) {
    _logger.fine('---- Removed Global, reason: unsupported type: '
        '${cursor.completeStringRepr()}');
    _logger.warning("Skipped global variable '$name', type not supported.");
    return null;
  }

  if (config.ffiNativeConfig.enabled) {
    _logger
        .warning("Skipped global variable '$name', not supported in Natives.");
    return null;
  }

  final global = Global(
    originalName: name,
    name: config.globals.renameUsingConfig(name),
    usr: usr,
    type: type,
    dartDoc: getCursorDocComment(cursor),
    exposeSymbolAddress: config.functionDecl.shouldIncludeSymbolAddress(name),
  );
  bindingsIndex.addGlobalVarToSeen(usr, global);
  return global;
}
