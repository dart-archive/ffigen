// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../includer.dart';
import '../utils.dart';

// TODO(#279): Logging
// final _logger = Logger('ffigen.header_parser.objcinterfacedecl_parser');

class _ParsedObjCInterface {
  ObjCInterface interface;
  _ParsedObjCInterface(this.interface);
}

class _ParsedObjCMethod {
  ObjCMethod method;
  bool hasError = false;
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

  final t = cursor.type();
  final name = t.spelling();

  return Type.objCInterface(ObjCInterface(
    usr: itfUsr, originalName: name,
    name: name, // TODO(#279): config.interfaceDecl.renameUsingConfig(name),
    dartDoc: getCursorDocComment(cursor),
  ));
}

void fillObjCInterfaceMethodsIfNeeded(
    ObjCInterface itf, clang_types.CXCursor cursor) {
  if (itf.filled) return;
  itf.filled = true; // Break cycles.

  _interfaceStack.push(_ParsedObjCInterface(itf));
  clang.clang_visitChildren(
      cursor,
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
  _interfaceStack.top.interface.superType =
      cursor.type().toCodeGenType().objCInterface;
}

void _parseProperty(clang_types.CXCursor cursor) {
  final itf = _interfaceStack.top.interface;
  final fieldName = cursor.spelling();
  final fieldType = cursor.type().toCodeGenType();
  final dartDoc = getCursorDocComment(cursor);
  final property = ObjCProperty(fieldName);

  final getter = ObjCMethod(
    originalName: clang
        .clang_Cursor_getObjCPropertyGetterName(cursor)
        .toStringAndDispose(),
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertyGetter,
  );
  getter.returnType = ObjCMethodType(fieldType);
  itf.addMethod(getter);

  final setter = ObjCMethod(
    originalName: clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose(),
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertySetter,
  );
  setter.returnType = ObjCMethodType(Type.nativeType(SupportedNativeType.Void));
  setter.params.add(ObjCMethodParam(fieldType, 'value'));
  itf.addMethod(setter);
}

void _parseMethod(clang_types.CXCursor cursor) {
  final method = ObjCMethod(
    originalName: cursor.spelling(),
    dartDoc: getCursorDocComment(cursor),
    kind: cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl
        ? ObjCMethodKind.classMethod
        : ObjCMethodKind.instanceMethod,
  );
  final parsed = _ParsedObjCMethod(method);
  _methodStack.push(parsed);
  clang.clang_visitChildren(
      cursor,
      Pointer.fromFunction(_parseMethodVisitor, exceptional_visitor_return),
      nullptr);
  _methodStack.pop();
  if (parsed.hasError || method.returnType == null) {
    // Discard it.
    return;
  }
  _interfaceStack.top.interface.addMethod(method);
}

int _parseMethodVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  switch (cursor.kind) {
    case clang_types.CXCursorKind.CXCursor_TypeRef:
    case clang_types.CXCursorKind.CXCursor_ObjCClassRef:
      _parseMethodReturnType(cursor);
      break;
    case clang_types.CXCursorKind.CXCursor_ParmDecl:
      _parseMethodParam(cursor);
      break;
    default:
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

void _parseMethodReturnType(clang_types.CXCursor cursor) {
  final parsed = _methodStack.top;
  if (parsed.method.returnType != null) {
    parsed.hasError = true;
  } else {
    parsed.method.returnType = ObjCMethodType(cursor.type().toCodeGenType());
  }
}

void _parseMethodParam(clang_types.CXCursor cursor) {
  _methodStack.top.method.params
      .add(ObjCMethodParam(cursor.type().toCodeGenType(), cursor.spelling()));
}
