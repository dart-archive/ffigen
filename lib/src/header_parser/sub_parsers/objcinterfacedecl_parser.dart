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
      Pointer.fromFunction(_parseInterfaceVisitor, exceptional_visitor_return),
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
      Pointer.fromFunction(
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
  final dartDoc = getCursorDocComment(cursor);

  final propertyAttributes =
      clang.clang_Cursor_getObjCPropertyAttributes(cursor, 0);
  final isClass = propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_class >
      0;
  final isReadOnly = propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_readonly >
      0;
  // TODO(#334): Use the nullable attribute to decide this.
  final isNullable =
      cursor.type().kind == clang_types.CXTypeKind.CXType_ObjCObjectPointer;

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
    isNullableReturn: isNullable,
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
        isClass: isClass);
    setter.returnType = NativeType(SupportedNativeType.Void);
    setter.params
        .add(ObjCMethodParam(fieldType, 'value', isNullable: isNullable));
    itf.addMethod(setter);
  }
}

void _parseMethod(clang_types.CXCursor cursor) {
  final methodName = cursor.spelling();
  final isClassMethod =
      cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl;
  final method = ObjCMethod(
    originalName: methodName,
    dartDoc: getCursorDocComment(cursor),
    kind: ObjCMethodKind.method,
    isClass: isClassMethod,
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
  /*
  TODO(#334): Change this to use:
  
  clang.clang_Type_getNullability(cursor.type()) ==
      clang_types.CXTypeNullabilityKind.CXTypeNullability_Nullable;

  NOTE: This will only work with the

    clang_types
      .CXTranslationUnit_Flags.CXTranslationUnit_IncludeAttributedTypes

  option set.
  */
  final isNullable =
      cursor.type().kind == clang_types.CXTypeKind.CXType_ObjCObjectPointer;
  final name = cursor.spelling();
  final type = cursor.type().toCodeGenType();
  _logger.fine(
      '           >> Parameter: $type $name ${cursor.completeStringRepr()}');
  _methodStack.top.method.params
      .add(ObjCMethodParam(type, name, isNullable: isNullable));
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
      Pointer.fromFunction(
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
      Pointer.fromFunction(_parseInterfaceVisitor, exceptional_visitor_return),
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
