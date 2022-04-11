// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffigen/src/code_generator.dart';
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

  _logger.fine('++++ Adding ObjC interface: '
      'Name: $name, ${cursor.completeStringRepr()}');

  return ObjCInterface(
    usr: itfUsr, originalName: name,
    name: name, // TODO(#279): config.interfaceDecl.renameUsingConfig(name),
    dartDoc: getCursorDocComment(cursor),
  );
}

void fillObjCInterfaceMethodsIfNeeded(
    ObjCInterface itf, clang_types.CXCursor cursor) {
  if (itf.filled) return;
  itf.filled = true; // Break cycles.

  _logger.fine('++++ Filling ObjC interface: '
      'Name: ${itf.originalName}, ${cursor.completeStringRepr()}');

  _interfaceStack.push(_ParsedObjCInterface(itf));
  clang.clang_visitChildren(
      cursor,
      Pointer.fromFunction(_parseInterfaceVisitor, exceptional_visitor_return),
      nullptr);
  _interfaceStack.pop();

  _logger.fine('++++ Finished ObjC interface: '
      'Name: ${itf.originalName}, ${cursor.completeStringRepr()}');
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
  final superType = cursor.type().toCodeGenType();
  _logger.fine('       > Super type: '
      '$superType ${cursor.completeStringRepr()}');
  final itf = _interfaceStack.top.interface;
  if (superType is ObjCInterface) {
    itf.superType = superType;
  } else {
    _logger.severe(
        'Super type of $itf is $superType, which is not a valid interface.');
  }
}

void _parseProperty(clang_types.CXCursor cursor) {
  final itf = _interfaceStack.top.interface;
  final fieldName = cursor.spelling();
  final fieldType = cursor.type().toCodeGenType();
  final dartDoc = getCursorDocComment(cursor);
  final property = ObjCProperty(fieldName);
  _logger.fine('       > Property: '
      '$fieldType $fieldName ${cursor.completeStringRepr()}');

  final getter = ObjCMethod(
    originalName: clang
        .clang_Cursor_getObjCPropertyGetterName(cursor)
        .toStringAndDispose(),
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertyGetter,
  );
  getter.returnType = fieldType;
  itf.addMethod(getter);

  final setter = ObjCMethod(
    originalName: clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose(),
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertySetter,
  );
  setter.returnType = NativeType(SupportedNativeType.Void);
  setter.params.add(ObjCMethodParam(fieldType, 'value'));
  itf.addMethod(setter);
}

void _parseMethod(clang_types.CXCursor cursor) {
  final isClassMethod =
      cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl;
  final method = ObjCMethod(
    originalName: cursor.spelling(),
    dartDoc: getCursorDocComment(cursor),
    kind: isClassMethod
        ? ObjCMethodKind.classMethod
        : ObjCMethodKind.instanceMethod,
  );
  final parsed = _ParsedObjCMethod(method);
  _logger.fine('       > ${isClassMethod ? 'Class' : 'Instance'} method: '
      '${method.originalName} ${cursor.completeStringRepr()}');
  _methodStack.push(parsed);
  clang.clang_visitChildren(
      cursor,
      Pointer.fromFunction(_parseMethodVisitor, exceptional_visitor_return),
      nullptr);
  _methodStack.pop();
  if (parsed.hasError) {
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
    _logger.fine(
        '           >> Extra return type: ${cursor.completeStringRepr()}');
    _logger.warning('Method "${parsed.method.originalName}" in instance '
        '"${_interfaceStack.top.interface.originalName}" has multiple return '
        'types.');
  } else {
    parsed.method.returnType = cursor.type().toCodeGenType();
    _logger.fine('           >> Return type: '
        '${parsed.method.returnType} ${cursor.completeStringRepr()}');
  }
}

void _parseMethodParam(clang_types.CXCursor cursor) {
  final name = cursor.spelling();
  final type = cursor.type().toCodeGenType();
  _logger.fine(
      '           >> Parameter: $type $name ${cursor.completeStringRepr()}');
  _methodStack.top.method.params.add(ObjCMethodParam(type, name));
}
