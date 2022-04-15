// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

ObjCBlock parseObjCBlock(clang_types.CXType cxtype) {
  final blk = clang.clang_getPointeeType(cxtype);
  final returnType = clang.clang_getResultType(blk).toCodeGenType();
  final argTypes = <Type>[];
  final int numArgs = clang.clang_getNumArgTypes(blk);
  for (int i = 0; i < numArgs; ++i) {
    argTypes.add(clang.clang_getArgType(blk, i).toCodeGenType());
  }

  // Create a fake USR code for the block. This code is used to dedupe blocks
  // with the same signature.
  // TODO(#279): These keys don't dedupe sufficiently.
  var usr = 'objcBlock: ' + returnType.hashCode.toRadixString(36);
  for (final type in argTypes) {
    usr += ' ' + type.hashCode.toRadixString(36);
  }

  return ObjCBlock(
    usr: usr.toString(),
    name: 'ObjCBlock',
    returnType: returnType,
    argTypes: argTypes,
  );
}
