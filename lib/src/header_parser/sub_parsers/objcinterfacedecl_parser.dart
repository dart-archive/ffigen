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

Pointer<
        NativeFunction<
            Int32 Function(
                clang_types.CXCursor, clang_types.CXCursor, Pointer<Void>)>>?
    _parseInterfaceVisitorPtr;
Pointer<
        NativeFunction<
            Int32 Function(
                clang_types.CXCursor, clang_types.CXCursor, Pointer<Void>)>>?
    _isClassDeclarationVisitorPtr;
Pointer<
        NativeFunction<
            Int32 Function(
                clang_types.CXCursor, clang_types.CXCursor, Pointer<Void>)>>?
    _parseMethodVisitorPtr;
Pointer<
        NativeFunction<
            Int32 Function(
                clang_types.CXCursor, clang_types.CXCursor, Pointer<Void>)>>?
    _findCategoryInterfaceVisitorPtr;

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

Type? parseObjCInterfaceDeclaration(
  clang_types.CXCursor cursor, {
  /// Option to ignore declaration filter (Useful in case of extracting
  /// declarations when they are passed/returned by an included function.)
  bool ignoreFilter = false,
}) {
  final itfUsr = cursor.usr();
  final itfName = cursor.spelling();
  if (!ignoreFilter && !shouldIncludeObjCInterface(itfUsr, itfName)) {
    return null;
  }

  final t = cursor.type();
  final name = t.spelling();

  _logger.fine('++++ Adding ObjC interface: '
      'Name: $name, ${cursor.completeStringRepr()}');

  return ObjCInterface(
    usr: itfUsr,
    originalName: name,
    name: config.objcInterfaces.renameUsingConfig(name),
    lookupName: config.objcModulePrefixer.applyPrefix(name),
    dartDoc: getCursorDocComment(cursor),
    builtInFunctions: objCBuiltInFunctions,
  );
}

void fillObjCInterfaceMethodsIfNeeded(
    ObjCInterface itf, clang_types.CXCursor cursor) {
  if (_isClassDeclaration(cursor)) {
    // @class declarations are ObjC's way of forward declaring classes. In that
    // case there's nothing to fill yet.
    return;
  }

  if (itf.filled) return;
  itf.filled = true; // Break cycles.

  _logger.fine('++++ Filling ObjC interface: '
      'Name: ${itf.originalName}, ${cursor.completeStringRepr()}');

  _interfaceStack.push(_ParsedObjCInterface(itf));
  clang.clang_visitChildren(
      cursor,
      _parseInterfaceVisitorPtr ??= Pointer.fromFunction(
          _parseInterfaceVisitor, exceptional_visitor_return),
      nullptr);
  _interfaceStack.pop();

  _logger.fine('++++ Finished ObjC interface: '
      'Name: ${itf.originalName}, ${cursor.completeStringRepr()}');
}

bool _isClassDeclarationResult = false;
bool _isClassDeclaration(clang_types.CXCursor cursor) {
  // It's a class declaration if it has no children other than ObjCClassRef.
  _isClassDeclarationResult = true;
  clang.clang_visitChildren(
      cursor,
      _isClassDeclarationVisitorPtr ??= Pointer.fromFunction(
          _isClassDeclarationVisitor, exceptional_visitor_return),
      nullptr);
  return _isClassDeclarationResult;
}

int _isClassDeclarationVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  if (cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassRef) {
    return clang_types.CXChildVisitResult.CXChildVisit_Continue;
  }
  _isClassDeclarationResult = false;
  return clang_types.CXChildVisitResult.CXChildVisit_Break;
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

  if (fieldType.isIncompleteCompound) {
    _logger.warning('Property "$fieldName" in instance "${itf.originalName}" '
        'has incomplete type: $fieldType.');
    return;
  }

  final dartDoc = getCursorDocComment(cursor);

  final propertyAttributes =
      clang.clang_Cursor_getObjCPropertyAttributes(cursor, 0);
  final isClass = propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_class >
      0;
  final isReadOnly = propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_readonly >
      0;

  final property = ObjCProperty(fieldName);

  _logger.fine('       > Property: '
      '$fieldType $fieldName ${cursor.completeStringRepr()}');

  final getterName =
      clang.clang_Cursor_getObjCPropertyGetterName(cursor).toStringAndDispose();
  final getter = ObjCMethod(
    originalName: getterName,
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertyGetter,
    isClass: isClass,
    returnType: fieldType,
  );
  itf.addMethod(getter);

  if (!isReadOnly) {
    final setterName = clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose();
    final setter = ObjCMethod(
        originalName: setterName,
        property: property,
        dartDoc: dartDoc,
        kind: ObjCMethodKind.propertySetter,
        isClass: isClass,
        returnType: NativeType(SupportedNativeType.Void));
    setter.params.add(ObjCMethodParam(fieldType, 'value'));
    itf.addMethod(setter);
  }
}

void _parseMethod(clang_types.CXCursor cursor) {
  final methodName = cursor.spelling();
  final isClassMethod =
      cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl;
  final returnType = clang.clang_getCursorResultType(cursor).toCodeGenType();
  if (returnType.isIncompleteCompound) {
    _logger.warning('Method "$methodName" in instance '
        '"${_interfaceStack.top.interface.originalName}" has incomplete '
        'return type: $returnType.');
    return;
  }
  final method = ObjCMethod(
    originalName: methodName,
    dartDoc: getCursorDocComment(cursor),
    kind: ObjCMethodKind.method,
    isClass: isClassMethod,
    returnType: returnType,
  );
  final parsed = _ParsedObjCMethod(method);
  _logger.fine('       > ${isClassMethod ? 'Class' : 'Instance'} method: '
      '${method.originalName} ${cursor.completeStringRepr()}');
  _methodStack.push(parsed);
  clang.clang_visitChildren(
      cursor,
      _parseMethodVisitorPtr ??=
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
    case clang_types.CXCursorKind.CXCursor_ParmDecl:
      _parseMethodParam(cursor);
      break;
    case clang_types.CXCursorKind.CXCursor_NSReturnsRetained:
      _markMethodReturnsRetained(cursor);
      break;
    default:
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

void _parseMethodParam(clang_types.CXCursor cursor) {
  final parsed = _methodStack.top;
  final name = cursor.spelling();
  final type = cursor.type().toCodeGenType();
  if (type.isIncompleteCompound) {
    parsed.hasError = true;
    _logger.warning('Method "${parsed.method.originalName}" in instance '
        '"${_interfaceStack.top.interface.originalName}" has incomplete '
        'parameter type: $type.');
    return;
  }
  _logger.fine(
      '           >> Parameter: $type $name ${cursor.completeStringRepr()}');
  parsed.method.params.add(ObjCMethodParam(type, name));
}

void _markMethodReturnsRetained(clang_types.CXCursor cursor) {
  _methodStack.top.method.returnsRetained = true;
}

BindingType? parseObjCCategoryDeclaration(clang_types.CXCursor cursor) {
  // Categories add methods to an existing interface, so first we run a visitor
  // to find the interface, then we fully parse that interface, then we run the
  // _parseInterfaceVisitor over the category to add its methods etc. Reusing
  // the interface visitor relies on the fact that the structure of the category
  // AST looks exactly the same as the interface AST, and that the category's
  // interface is a different kind of node to the interface's super type (so is
  // ignored by _parseInterfaceVisitor).
  final name = cursor.spelling();
  _logger.fine('++++ Adding ObjC category: '
      'Name: $name, ${cursor.completeStringRepr()}');

  _findCategoryInterfaceVisitorResult = null;
  clang.clang_visitChildren(
      cursor,
      _findCategoryInterfaceVisitorPtr ??= Pointer.fromFunction(
          _findCategoryInterfaceVisitor, exceptional_visitor_return),
      nullptr);
  final itfCursor = _findCategoryInterfaceVisitorResult;
  if (itfCursor == null) {
    _logger.severe('Category $name has no interface.');
    return null;
  }

  // TODO(#347): Currently any interface with a category bypasses the filters.
  final itf = itfCursor.type().toCodeGenType();
  if (itf is! ObjCInterface) {
    _logger.severe(
        'Interface of category $name is $itf, which is not a valid interface.');
    return null;
  }

  _interfaceStack.push(_ParsedObjCInterface(itf));
  clang.clang_visitChildren(
      cursor,
      _parseInterfaceVisitorPtr ??= Pointer.fromFunction(
          _parseInterfaceVisitor, exceptional_visitor_return),
      nullptr);
  _interfaceStack.pop();

  _logger.fine('++++ Finished ObjC category: '
      'Name: $name, ${cursor.completeStringRepr()}');

  return itf;
}

clang_types.CXCursor? _findCategoryInterfaceVisitorResult;
int _findCategoryInterfaceVisitor(clang_types.CXCursor cursor,
    clang_types.CXCursor parent, Pointer<Void> clientData) {
  if (cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassRef) {
    _findCategoryInterfaceVisitorResult = cursor;
    return clang_types.CXChildVisitResult.CXChildVisit_Break;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}
