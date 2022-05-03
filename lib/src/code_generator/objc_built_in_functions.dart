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
  late final registerName = ObjCInternalFunction(
      '_registerName', _registerNameFunc, (Writer w, String name) {
    final s = StringBuffer();
    final selType = _registerNameFunc.functionType.returnType.getCType(w);
    s.write('\n$selType $name(String name) {\n');
    s.write('  final cstr = name.toNativeUtf8();\n');
    s.write('  final sel = ${_registerNameFunc.name}(cstr.cast());\n');
    s.write('  ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);\n');
    s.write('  return sel;\n');
    s.write('}\n');
    return s.toString();
  });

  late final _getClassFunc = Func(
    name: '_objc_getClass',
    originalName: 'objc_getClass',
    returnType: PointerType(objCObjectType),
    parameters: [Parameter(name: 'str', type: PointerType(charType))],
    isInternal: true,
  );
  late final getClass =
      ObjCInternalFunction('_getClass', _getClassFunc, (Writer w, String name) {
    final s = StringBuffer();
    final objType = _getClassFunc.functionType.returnType.getCType(w);
    s.write('\n$objType $name(String name) {\n');
    s.write('  final cstr = name.toNativeUtf8();\n');
    s.write('  final clazz = ${_getClassFunc.name}(cstr.cast());\n');
    s.write('  ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);\n');
    s.write('  return clazz;\n');
    s.write('}\n');
    return s.toString();
  });

  // We need to load a separate instance of objc_msgSend for each signature.
  final _msgSendFuncs = <String, Func>{};
  Func getMsgSendFunc(Type returnType, List<ObjCMethodParam> params) {
    var key = returnType.cacheKey();
    for (final p in params) {
      key += ' ' + p.type.cacheKey();
    }
    return _msgSendFuncs[key] ??= Func(
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
  }

  final _selObjects = <String, ObjCInternalGlobal>{};
  ObjCInternalGlobal getSelObject(String methodName) {
    return _selObjects[methodName] ??= ObjCInternalGlobal(
        PointerType(objCSelType),
        '_sel_${methodName.replaceAll(":", "_")}',
        () => '${registerName.name}("$methodName")');
  }

  // See https://clang.llvm.org/docs/Block-ABI-Apple.html
  late final blockStruct = Struct(
    name: '_ObjCBlock',
    isInternal: true,
    members: [
      Member(name: 'isa', type: PointerType(voidType)),
      Member(name: 'flags', type: intType),
      Member(name: 'reserved', type: intType),
      Member(name: 'invoke', type: PointerType(voidType)),
      Member(name: 'descriptor', type: PointerType(blockDescStruct)),
      Member(name: 'target', type: PointerType(voidType)),
    ],
  );
  late final blockDescStruct = Struct(
    name: '_ObjCBlockDesc',
    isInternal: true,
    members: [
      Member(name: 'reserved', type: unsignedLongType),
      Member(name: 'size', type: unsignedLongType),
      Member(name: 'copy_helper', type: PointerType(voidType)),
      Member(name: 'dispose_helper', type: PointerType(voidType)),
      Member(name: 'signature', type: PointerType(charType)),
    ],
  );
  late final newBlockDesc =
      ObjCInternalFunction('_newBlockDesc', null, (Writer w, String name) {
    final s = StringBuffer();
    final blockType = blockStruct.getCType(w);
    final descType = blockDescStruct.getCType(w);
    final descPtr = PointerType(blockDescStruct).getCType(w);
    s.write('\n$descPtr $name() {\n');
    s.write('  final d = ${w.ffiPkgLibraryPrefix}.calloc.allocate<$descType>('
        '${w.ffiLibraryPrefix}.sizeOf<$descType>());\n');
    s.write('  d.ref.size = ${w.ffiLibraryPrefix}.sizeOf<$blockType>();\n');
    s.write('  return d;\n');
    s.write('}\n');
    return s.toString();
  });
  late final blockDescSingleton = ObjCInternalGlobal(
    PointerType(blockDescStruct),
    '_objc_block_desc',
    () => '${newBlockDesc.name}()',
  );
  late final newBlock =
      ObjCInternalFunction('_newBlock', null, (Writer w, String name) {
    final s = StringBuffer();
    final blockType = blockStruct.getCType(w);
    final blockPtr = PointerType(blockStruct).getCType(w);
    final voidPtr = PointerType(voidType).getCType(w);
    s.write('\n$blockPtr $name($voidPtr invoke, $voidPtr target) {\n');
    s.write('  final b = ${w.ffiPkgLibraryPrefix}.calloc.allocate<$blockType>('
        '${w.ffiLibraryPrefix}.sizeOf<$blockType>());\n');
    s.write('  b.ref.invoke = invoke;\n');
    s.write('  b.ref.target = target;\n');
    s.write('  b.ref.descriptor = ${blockDescSingleton.name};\n');
    s.write('  return b;\n');
    s.write('}\n');
    return s.toString();
  });

  bool utilsExist = false;
  void ensureUtilsExist(Writer w, StringBuffer s) {
    if (utilsExist) return;
    utilsExist = true;

    final objType = PointerType(objCObjectType).getCType(w);
    s.write('''
class _ObjCWrapper {
  final $objType _id;
  final ${w.className} _lib;

  _ObjCWrapper._(this._id, this._lib);

  @override
  bool operator ==(Object other) {
    return other is _ObjCWrapper && _id == other._id;
  }

  @override
  int get hashCode => _id.hashCode;
}
''');
  }

  void addDependencies(Set<Binding> dependencies) {
    registerName.addDependencies(dependencies);
    getClass.addDependencies(dependencies);
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
    s.write('  String toString() => (UTF8String).cast<'
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

/// Functions only used internally by ObjC bindings, which may or may not wrap a
/// native function, such as getClass.
class ObjCInternalFunction extends LookUpBinding {
  final Func? _wrappedFunction;
  final String Function(Writer, String) _toBindingString;

  ObjCInternalFunction(
      String name, this._wrappedFunction, this._toBindingString)
      : super(originalName: name, name: name, isInternal: true);

  @override
  BindingString toBindingString(Writer w) {
    name = w.wrapperLevelUniqueNamer.makeUnique(name);
    return BindingString(
        type: BindingStringType.func, string: _toBindingString(w, name));
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    _wrappedFunction?.addDependencies(dependencies);
  }
}

/// Globals only used internally by ObjC bindings, such as classes and SELs.
class ObjCInternalGlobal extends LookUpBinding {
  final Type type;
  final String Function() makeValue;

  ObjCInternalGlobal(this.type, String name, this.makeValue)
      : super(originalName: name, name: name, isInternal: true);

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
