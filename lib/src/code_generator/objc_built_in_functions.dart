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
    final selType = _registerNameFunc.functionType.returnType.getCType(w);
    return '''
$selType $name(String name) {
  final cstr = name.toNativeUtf8();
  final sel = ${_registerNameFunc.name}(cstr.cast());
  ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);
  return sel;
}
''';
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
    final objType = _getClassFunc.functionType.returnType.getCType(w);
    return '''
$objType $name(String name) {
  final cstr = name.toNativeUtf8();
  final clazz = ${_getClassFunc.name}(cstr.cast());
  ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);
  if (clazz == ${w.ffiLibraryPrefix}.nullptr) {
    throw Exception('Failed to load Objective-C class: \$name');
  }
  return clazz;
}
''';
  });

  late final _retainFunc = Func(
    name: '_objc_retain',
    originalName: 'objc_retain',
    returnType: PointerType(objCObjectType),
    parameters: [Parameter(name: 'value', type: PointerType(objCObjectType))],
    isInternal: true,
  );
  late final _releaseFunc = Func(
    name: '_objc_release',
    originalName: 'objc_release',
    returnType: voidType,
    parameters: [Parameter(name: 'value', type: PointerType(objCObjectType))],
    isInternal: true,
  );
  late final _releaseFinalizer = ObjCInternalGlobal(
    '_objc_releaseFinalizer',
    (Writer w) => '${w.ffiLibraryPrefix}.NativeFinalizer('
        '${_releaseFunc.funcPointerName}.cast())',
    _releaseFunc,
  );

  late final _blockCopyFunc = Func(
    name: '_Block_copy',
    originalName: '_Block_copy',
    returnType: PointerType(voidType),
    parameters: [Parameter(name: 'value', type: PointerType(voidType))],
    isInternal: true,
  );
  late final _blockReleaseFunc = Func(
    name: '_Block_release',
    originalName: '_Block_release',
    returnType: voidType,
    parameters: [Parameter(name: 'value', type: PointerType(voidType))],
    isInternal: true,
  );
  late final _blockReleaseFinalizer = ObjCInternalGlobal(
    '_objc_releaseFinalizer',
    (Writer w) => '${w.ffiLibraryPrefix}.NativeFinalizer('
        '${_blockReleaseFunc.funcPointerName}.cast())',
    _blockReleaseFunc,
  );

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
      '_sel_${methodName.replaceAll(":", "_")}',
      (Writer w) => '${registerName.name}("$methodName")',
      registerName,
    );
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
    final blockType = blockStruct.getCType(w);
    final descType = blockDescStruct.getCType(w);
    final descPtr = PointerType(blockDescStruct).getCType(w);
    return '''
$descPtr $name() {
  final d = ${w.ffiPkgLibraryPrefix}.calloc.allocate<$descType>(
      ${w.ffiLibraryPrefix}.sizeOf<$descType>());
  d.ref.reserved = 0;
  d.ref.size = ${w.ffiLibraryPrefix}.sizeOf<$blockType>();
  d.ref.copy_helper = ${w.ffiLibraryPrefix}.nullptr;
  d.ref.dispose_helper = ${w.ffiLibraryPrefix}.nullptr;
  d.ref.signature = ${w.ffiLibraryPrefix}.nullptr;
  return d;
}
''';
  });
  late final blockDescSingleton = ObjCInternalGlobal(
    '_objc_block_desc',
    (Writer w) => '${newBlockDesc.name}()',
    blockDescStruct,
  );
  late final concreteGlobalBlock = ObjCInternalGlobal(
    '_objc_concrete_global_block',
    (Writer w) => '${w.lookupFuncIdentifier}<${voidType.getCType(w)}>('
        "'_NSConcreteGlobalBlock')",
  );
  late final newBlock = ObjCInternalFunction('_newBlock', _blockCopyFunc,
      (Writer w, String name) {
    final blockType = blockStruct.getCType(w);
    final blockPtr = PointerType(blockStruct).getCType(w);
    final voidPtr = PointerType(voidType).getCType(w);
    return '''
$blockPtr $name($voidPtr invoke, $voidPtr target) {
  final b = ${w.ffiPkgLibraryPrefix}.calloc.allocate<$blockType>(
      ${w.ffiLibraryPrefix}.sizeOf<$blockType>());
  b.ref.isa = ${concreteGlobalBlock.name};
  b.ref.flags = 0;
  b.ref.reserved = 0;
  b.ref.invoke = invoke;
  b.ref.target = target;
  b.ref.descriptor = ${blockDescSingleton.name};
  final copy = ${_blockCopyFunc.name}(b.cast()).cast<$blockType>();
  ${w.ffiPkgLibraryPrefix}.calloc.free(b);
  return copy;
}
''';
  });

  void _writeFinalizableClass(
      Writer w,
      StringBuffer s,
      String name,
      String kind,
      String idType,
      String retain,
      String release,
      String finalizer) {
    s.write('''
class $name implements ${w.ffiLibraryPrefix}.Finalizable {
  final $idType _id;
  final ${w.className} _lib;
  bool _pendingRelease;

  $name._(this._id, this._lib,
      {bool retain = false, bool release = false}) : _pendingRelease = release {
    if (retain) {
      _lib.$retain(_id.cast());
    }
    if (release) {
      _lib.$finalizer.attach(this, _id.cast(), detach: this);
    }
  }

  /// Releases the reference to the underlying ObjC $kind held by this wrapper.
  /// Throws a StateError if this wrapper doesn't currently hold a reference.
  void release() {
    if (_pendingRelease) {
      _pendingRelease = false;
      _lib.$release(_id.cast());
      _lib.$finalizer.detach(this);
    } else {
      throw StateError(
          'Released an ObjC $kind that was unowned or already released.');
    }
  }

  @override
  bool operator ==(Object other) {
    return other is $name && _id == other._id;
  }

  @override
  int get hashCode => _id.hashCode;
}
''');
  }

  bool utilsExist = false;
  void ensureUtilsExist(Writer w, StringBuffer s) {
    if (utilsExist) return;
    utilsExist = true;
    _writeFinalizableClass(
        w,
        s,
        '_ObjCWrapper',
        'object',
        PointerType(objCObjectType).getCType(w),
        _retainFunc.name,
        _releaseFunc.name,
        _releaseFinalizer.name);
  }

  bool blockUtilsExist = false;
  void ensureBlockUtilsExist(Writer w, StringBuffer s) {
    if (blockUtilsExist) return;
    blockUtilsExist = true;
    _writeFinalizableClass(
        w,
        s,
        '_ObjCBlockBase',
        'block',
        PointerType(blockStruct).getCType(w),
        _blockCopyFunc.name,
        _blockReleaseFunc.name,
        _blockReleaseFinalizer.name);
  }

  void addDependencies(Set<Binding> dependencies) {
    registerName.addDependencies(dependencies);
    getClass.addDependencies(dependencies);
    _retainFunc.addDependencies(dependencies);
    _releaseFunc.addDependencies(dependencies);
    _releaseFinalizer.addDependencies(dependencies);
    for (final func in _msgSendFuncs.values) {
      func.addDependencies(dependencies);
    }
    for (final sel in _selObjects.values) {
      sel.addDependencies(dependencies);
    }
  }

  void addBlockDependencies(Set<Binding> dependencies) {
    newBlockDesc.addDependencies(dependencies);
    blockDescSingleton.addDependencies(dependencies);
    blockStruct.addDependencies(dependencies);
    concreteGlobalBlock.addDependencies(dependencies);
    newBlock.addDependencies(dependencies);
    _blockCopyFunc.addDependencies(dependencies);
    _blockReleaseFunc.addDependencies(dependencies);
    _blockReleaseFinalizer.addDependencies(dependencies);
  }

  final _interfaceRegistry = <String, ObjCInterface>{};
  void registerInterface(ObjCInterface interface) {
    _interfaceRegistry[interface.originalName] = interface;
  }

  ObjCInterface get nsData {
    return _interfaceRegistry["NSData"] ??
        (ObjCInterface(
          originalName: "NSData",
          builtInFunctions: this,
          isBuiltIn: true,
        ));
  }

  void generateNSStringUtils(Writer w, StringBuffer s) {
    // Generate a constructor that wraps stringWithCharacters, and a toString
    // method that wraps dataUsingEncoding.
    s.write('''
  factory NSString(${w.className} _lib, String str) {
    final cstr = str.toNativeUtf16();
    final nsstr = stringWithCharacters_length_(_lib, cstr.cast(), str.length);
    ${w.ffiPkgLibraryPrefix}.calloc.free(cstr);
    return nsstr;
  }

  @override
  String toString() {
    final data = dataUsingEncoding_(
        0x94000100 /* NSUTF16LittleEndianStringEncoding */);
    return data.bytes.cast<${w.ffiPkgLibraryPrefix}.Utf16>().toDartString(
        length: length);
  }
''');
  }

  void generateStringUtils(Writer w, StringBuffer s) {
    // Generate an extension on String to convert to NSString
    s.write('''
extension StringToNSString on String {
  NSString toNSString(${w.className} lib) => NSString(lib, this);
}
''');
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
  final String Function(Writer) makeValue;
  Binding? binding;

  ObjCInternalGlobal(String name, this.makeValue, [this.binding])
      : super(originalName: name, name: name, isInternal: true);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    name = w.wrapperLevelUniqueNamer.makeUnique(name);
    s.write('late final $name = ${makeValue(w)};');
    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    binding?.addDependencies(dependencies);
  }
}
