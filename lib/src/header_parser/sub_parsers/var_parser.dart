// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.var_parser');

/// Parses a global variable
Global? parseVarDefinition(clang_types.CXCursor cursor) {
  final type = cursor.type().toCodeGenType();
  if (type.broadType == BroadType.Unimplemented) {
    _logger
        .warning('Global Type not supported $type ${cursor.type().spelling()}');
    return null;
  }
  final g = Global(
    originalName: cursor.spelling(),
    name: config.globals.renameUsingConfig(cursor.spelling()),
    usr: cursor.usr(),
    type: cursor.type().toCodeGenType(),
    dartDoc: getCursorDocComment(cursor),
  );
  return g;
}
