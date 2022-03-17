// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../includer.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.objcinterfacedecl_parser');

class _ParsedObjCInterface {
  ObjCInterface interface;
  _ParsedObjCInterface(this.interface);
}

class _ParsedObjCMethod {
  ObjCMethod method;
  _ParsedObjCMethod(this.method);
}

final _interfaceStack = Stack<_ParsedObjCInterface>();
final _methodStack = Stack<_ParsedObjCMethod>();

Type? parseObjCInterfaceDeclaration(clang_types.CXCursor cursor) {
  final itfUsr = cursor.usr();
  final itfName = cursor.spelling();
  if (!shouldIncludeInterface(itfUsr, itfName)) {
    return null;
  }

  // print('    ${cursor.completeStringRepr()}');
  final t = cursor.type();
  // print('      type: ${t.completeStringRepr()}');
  final name = t.spelling();

  return Type.objCInterface(ObjCInterface(
      usr: itfUsr, originalName: name,
      // name: config.interfaceDecl.renameUsingConfig(name),
      name: name,
      dartDoc: getCursorDocComment(cursor),
    ));
}

void fillObjCInterfaceMethodsIfNeeded(ObjCInterface itf, clang_types.CXCursor cursor) {
  _interfaceStack.push(_ParsedObjCInterface(itf));

  clang.clang_visitChildren(cursor,
      Pointer.fromFunction(_parseInterfaceVisitor, exceptional_visitor_return),
      nullptr);

  _interfaceStack.pop();
}

int _parseInterfaceVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  switch (cursor.kind) {
    case clang_types.CXCursorKind.CXCursor_ObjCSuperClassRef:
      _parseSuperType(cursor);
      break;
    case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
      _parseProperty(cursor);
      break;
    case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
    case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
      _parseMethod(cursor);
      break;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

void _parseSuperType(clang_types.CXCursor cursor) {
  // print('        Super type: ${cursor.type().completeStringRepr()}');
}

void _parseProperty(clang_types.CXCursor cursor) {
  // print('        Member: ${cursor.spelling()}   ${cursor.type().completeStringRepr()}');
  // print('            ${clang.clang_Cursor_getObjCPropertyGetterName(cursor).toStringAndDispose()}');
  // print('            ${clang.clang_Cursor_getObjCPropertySetterName(cursor).toStringAndDispose()}');
}

void _parseMethod(clang_types.CXCursor cursor) {
  // print('        Method: ${cursor.spelling()}');
  clang.clang_visitChildren(cursor,
      Pointer.fromFunction(_parseMethodVisitor, exceptional_visitor_return),
      nullptr);
}

int _parseMethodVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  switch (cursor.kind) {
    case clang_types.CXCursorKind.CXCursor_TypeRef:
    case clang_types.CXCursorKind.CXCursor_ObjCClassRef:
      // print('                  Return type: ${cursor.type().completeStringRepr()}');
      break;
    case clang_types.CXCursorKind.CXCursor_ParmDecl:
      // print('                  Param: ${cursor.spelling()}   ${cursor.type().completeStringRepr()}');
      break;
    default:
      // print('            !!!UNKNOWN!!!  ${cursor.completeStringRepr()}');
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
