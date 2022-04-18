// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'writer.dart';

/// Built in functions used by the Objective C bindings.
class ObjCBuiltInFunctions {
  late final _registerNameFunc = Func(
    name: '_sel_registerName',
    originalName: 'sel_registerName',
    returnType: PointerType(objCSelType),
    parameters: [Parameter(name: 'str', type: PointerType(charType))],
    isInternal: true,
  );
  late final String registerName;

  late final _getClassFunc = Func(
    name: '_objc_getClass',
    originalName: 'objc_getClass',
    returnType: PointerType(objCObjectType),
    parameters: [Parameter(name: 'str', type: PointerType(charType))],
    isInternal: true,
  );
  late final String getClass;

  // We need to load a separate instance of objc_msgSend for each signature.
  final _msgSendFuncs = <String, Func>{};
  Func getMsgSendFunc(Type returnType, List<ObjCMethodParam> params) {
    var key = returnType.cacheKey();
    for (final p in params) {
      key += ' ' + p.type.cacheKey();
    }
    _msgSendFuncs[key] ??= Func(
      name: '_objc_msgSend_${_msgSendFuncs.length}',
      originalName: 'objc_msgSend',
      returnType: returnType,
      parameters: [
        Parameter(name: 'obj', type: PointerType(objCObjectType)),
        Parameter(name: 'sel', type: PointerType(objCSelType)),
        for (final p in params) Parameter(name: p.name, type: p.type),
      ],
      isInternal: true,
    );
    return _msgSendFuncs[key]!;
  }

  final _selObjects = <String, ObjCInternalGlobal>{};
  ObjCInternalGlobal getSelObject(String methodName) {
    return _selObjects[methodName] ??= ObjCInternalGlobal(
        PointerType(objCSelType),
        '_sel_${methodName.replaceAll(":", "_")}',
        () => '$registerName(this, "$methodName")');
  }

  bool utilsExist = false;
  void ensureUtilsExist(Writer w, StringBuffer s) {
    if (utilsExist) return;
    utilsExist = true;

    registerName = w.topLevelUniqueNamer.makeUnique('_registerName');
    final selType = _registerNameFunc.functionType.returnType.getCType(w);
    s.write('\n$selType $registerName(${w.className} _lib, String name) {\n');
    s.write('  final cstr = name.toNativeUtf8();\n');
    s.write('  final sel = _lib.${_registerNameFunc.name}(cstr.cast());\n');
    s.write('  ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);\n');
    s.write('  return sel;\n');
    s.write('}\n');

    getClass = w.topLevelUniqueNamer.makeUnique('_getClass');
    final objType = _getClassFunc.functionType.returnType.getCType(w);
    s.write('\n$objType $getClass(${w.className} _lib, String name) {\n');
    s.write('  final cstr = name.toNativeUtf8();\n');
    s.write('  final clazz = _lib.${_getClassFunc.name}(cstr.cast());\n');
    s.write('  ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);\n');
    s.write('  return clazz;\n');
    s.write('}\n');

    s.write('\nclass _ObjCWrapper {\n');
    s.write('  final $objType _id;\n');
    s.write('  final ${w.className} _lib;\n');
    s.write('  _ObjCWrapper._(this._id, this._lib);\n');
    s.write('}\n');
  }

  void addDependencies(Set<Binding> dependencies) {
    _registerNameFunc.addDependencies(dependencies);
    _getClassFunc.addDependencies(dependencies);
    for (final func in _msgSendFuncs.values) {
      func.addDependencies(dependencies);
    }
    for (final sel in _selObjects.values) {
      sel.addDependencies(dependencies);
    }
  }

  void generateNSStringUtils(Writer w, StringBuffer s) {
    // Generate a constructor that wraps stringWithCString.
    s.write('  factory NSString(${w.className} _lib, String str) {\n');
    s.write('    final cstr = str.toNativeUtf8();\n');
    s.write('    final nsstr = stringWithCString_encoding('
        '_lib, cstr.cast(), 4 /* UTF8 */);\n');
    s.write('    ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);\n');
    s.write('    return nsstr;\n');
    s.write('  }\n\n');

    // Generate a toString method that wraps UTF8String.
    s.write('  @override\n');
    s.write('  String toString() => UTF8String().cast<'
        '${w.ffiPkgLibraryPrefix}.Utf8>().toDartString();\n\n');
  }

  void generateStringUtils(Writer w, StringBuffer s) {
    // Generate an extension on String to convert to NSString
    s.write('extension StringToNSString on String {\n');
    s.write('  NSString toNSString(${w.className} lib) => '
        'NSString(lib, this);\n');
    s.write('}\n\n');
  }
}

/// Globals only used internally by ObjC bindings, such as classes and SELs.
class ObjCInternalGlobal extends LookUpBinding {
  final Type type;
  final String Function() makeValue;

  ObjCInternalGlobal(this.type, String name, this.makeValue)
      : super(originalName: name, name: name);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    name = w.wrapperLevelUniqueNamer.makeUnique(name);
    s.write('late final ${type.getCType(w)} $name = ${makeValue()};');
    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    type.addDependencies(dependencies);
  }
}

/// Functions only used internally by ObjC bindings, such as getClass.
class ObjCInternalFunction extends LookUpBinding {
  final Func _wrapped;
  final BindingString Function(Writer) _toBindingString;

  ObjCInternalFunction(this._wrapped, this._toBindingString);

  @override
  BindingString toBindingString(Writer w) => _toBindingString(w);

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    _wrapped.addDependencies(dependencies);
  }
}
