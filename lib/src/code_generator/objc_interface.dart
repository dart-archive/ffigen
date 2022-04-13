// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

// Class methods defined on NSObject that we don't want to copy to child objects
// by default.
const _excludedNSObjectClassMethods = {
  'allocWithZone:',
  'class',
  'conformsToProtocol:',
  'copyWithZone:',
  'debugDescription',
  'description',
  'hash',
  'initialize',
  'instanceMethodForSelector:',
  'instanceMethodSignatureForSelector:',
  'instancesRespondToSelector:',
  'isSubclassOfClass:',
  'load',
  'mutableCopyWithZone:',
  'resolveClassMethod:',
  'resolveInstanceMethod:',
  'superclass',
};

class _ObjCBuiltInFunctions {
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
    // TODO(#279): These keys don't dedupe sufficiently.
    var key = returnType.hashCode.toRadixString(36);
    for (final p in params) {
      key += ' ' + p.type.hashCode.toRadixString(36);
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

final _builtInFunctions = _ObjCBuiltInFunctions();

class ObjCInterface extends BindingType {
  ObjCInterface? superType;
  final methods = <ObjCMethod>[];
  bool filled = false;

  // Objective C supports overriding class methods, but Dart doesn't support
  // overriding static methods. So in our generated Dart code, child classes
  // must explicitly implement all the class methods of their super type. To
  // help with this, we store the class methods in this map, as well as in the
  // methods list.
  final classMethods = <String, ObjCMethod>{};

  ObjCInterface({
    String? usr,
    required String originalName,
    required String name,
    String? dartDoc,
  }) : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

  bool get isNSString => name == "NSString";

  @override
  BindingString toBindingString(Writer w) {
    String paramsToString(List<ObjCMethodParam> params,
        {required bool isStatic}) {
      final List<String> stringParams = [];

      if (isStatic) {
        stringParams.add('${w.className} _lib');
      }
      stringParams.addAll(
          params.map((p) => '${_getConvertedType(p.type, w, name)} ${p.name}'));
      return '(' + stringParams.join(", ") + ')';
    }

    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    final uniqueNamer = UniqueNamer({name});
    final natLib = w.className;

    _builtInFunctions.ensureUtilsExist(w, s);
    final objType = PointerType(objCObjectType).getCType(w);
    final selType = PointerType(objCSelType).getCType(w);

    // Class declaration.
    s.write('class $name ');
    uniqueNamer.markUsed('_id');
    s.write('extends ${superType?.name ?? '_ObjCWrapper'} {\n');
    s.write('  $name._($objType id, $natLib lib) : super._(id, lib);\n\n');

    // Class object, used to call static methods.
    final classObject = uniqueNamer.makeUnique('_class');
    s.write('  static $objType? $classObject;\n\n');

    // Cast method.
    s.write('  static $name castFrom<T extends _ObjCWrapper>(T other) {\n');
    s.write('    return $name._(other._id, other._lib);\n');
    s.write('  }\n\n');

    if (isNSString) {
      _builtInFunctions.generateNSStringUtils(w, s);
    }

    // Methods.
    for (final m in methods) {
      final methodName = m._getDartMethodName(uniqueNamer);
      final selName = uniqueNamer.makeUnique('_sel_$methodName');
      final isStatic = m.isClass;
      final returnType = m.returnType!;

      // SEL object for the method.
      s.write('  static $selType? $selName;');

      // The method declaration.
      if (m.dartDoc != null) {
        s.write(makeDartDoc(m.dartDoc!));
      }

      s.write('  ');
      if (isStatic) {
        s.write('static ');
        s.write(_getConvertedType(returnType, w, name));

        switch (m.kind) {
          case ObjCMethodKind.method:
            // static returnType methodName(NativeLibrary _lib, ...)
            s.write(' $methodName');
            break;
          case ObjCMethodKind.propertyGetter:
            // static returnType getMethodName(NativeLibrary _lib)
            s.write(' get');
            s.write(methodName[0].toUpperCase() + methodName.substring(1));
            break;
          case ObjCMethodKind.propertySetter:
            // static void setMethodName(NativeLibrary _lib, ...)
            s.write(' set');
            s.write(methodName[0].toUpperCase() + methodName.substring(1));
            break;
        }
        s.write(paramsToString(m.params, isStatic: true));
      } else {
        if (superType?.hasMethod(m) ?? false) {
          s.write('@override\n  ');
        }
        switch (m.kind) {
          case ObjCMethodKind.method:
            // returnType methodName(...)
            s.write(_getConvertedType(returnType, w, name));
            s.write(' $methodName');
            s.write(paramsToString(m.params, isStatic: false));
            break;
          case ObjCMethodKind.propertyGetter:
            // returnType get methodName
            s.write(_getConvertedType(returnType, w, name));
            s.write(' get $methodName');
            break;
          case ObjCMethodKind.propertySetter:
            // set methodName(...)
            s.write('set $methodName');
            s.write(paramsToString(m.params, isStatic: false));
            break;
        }
      }

      s.write(' {\n');

      // Implementation.
      if (isStatic) {
        s.write('    $classObject ??= '
            '${_builtInFunctions.getClass}(_lib, "$originalName");\n');
      }
      s.write('    $selName ??= '
          '${_builtInFunctions.registerName}(_lib, "${m.originalName}");\n');
      final convertReturn = m.kind != ObjCMethodKind.propertySetter &&
          _needsConverting(returnType);

      if (returnType != NativeType(SupportedNativeType.Void)) {
        s.write('    ${convertReturn ? 'final _ret = ' : 'return '}');
      }
      s.write('_lib.${m.msgSend!.name}(');
      s.write(isStatic ? '_class!' : '_id');
      s.write(', $selName!');
      for (final p in m.params) {
        s.write(', ${_doArgConversion(p.type, p.name)}');
      }
      s.write(');\n');
      if (convertReturn) {
        final result = _doReturnConversion(returnType, '_ret', name, '_lib');
        s.write('    return $result;');
      }

      s.write('  }\n\n');
    }

    s.write('}\n\n');

    if (isNSString) {
      _builtInFunctions.generateStringUtils(w, s);
    }

    return BindingString(
        type: BindingStringType.objcInterface, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);

    if (isNSString) {
      _addNSStringMethods();
    }

    _filterPropertyMethods();

    if (superType != null) {
      superType!.addDependencies(dependencies);
      _copyClassMethodsFromSuperType();
    }

    for (final m in methods) {
      m.addDependencies(dependencies);
    }

    _builtInFunctions.addDependencies(dependencies);
  }

  void _filterPropertyMethods() {
    // Properties setters and getters are duplicated in the AST. One copy is
    // marked it with ObjCMethodKind.propertyGetter/Setter. The other copy is
    // missing important information, and is a plain old instanceMethod. So we
    // need to discard the second copy.
    final properties = Set<String>.from(
        methods.where((m) => m.isProperty).map((m) => m.originalName));
    methods.removeWhere(
        (m) => !m.isProperty && properties.contains(m.originalName));
  }

  void _copyClassMethodsFromSuperType() {
    // Copy class methods from the super type, because Dart classes don't
    // inherit static methods.
    for (final m in superType!.classMethods.values) {
      if (!_excludedNSObjectClassMethods.contains(m.originalName)) {
        addMethod(m);
      }
    }
  }

  void addMethod(ObjCMethod method) {
    methods.add(method);
    if (method.kind == ObjCMethodKind.method && method.isClass) {
      classMethods[method.originalName] ??= method;
    }
  }

  bool hasMethod(ObjCMethod method) {
    return methods.any(
        (m) => m.originalName == method.originalName && m.kind == method.kind);
  }

  void addMethodIfMissing(ObjCMethod method) {
    if (!hasMethod(method)) {
      addMethod(method);
    }
  }

  void _addNSStringMethods() {
    addMethodIfMissing(ObjCMethod(
      originalName: 'stringWithCString:encoding:',
      kind: ObjCMethodKind.method,
      isClass: true,
      returnType: this,
      params_: [
        ObjCMethodParam(PointerType(charType), 'cString'),
        ObjCMethodParam(unsignedIntType, 'enc'),
      ],
    ));
    addMethodIfMissing(ObjCMethod(
      originalName: 'UTF8String',
      kind: ObjCMethodKind.method,
      isClass: false,
      returnType: PointerType(charType),
      params_: [],
    ));
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);

  bool _isObject(Type type) =>
      type is PointerType && type.child == objCObjectType;

  bool _isInstanceType(Type type) =>
      type is Typealias &&
      type.originalName == 'instancetype' &&
      _isObject(type.type);

  // Utils for converting between the internal types passed to native code, and
  // the external types visible to the user. For example, ObjCInterfaces are
  // passed to native as Pointer<ObjCObject>, but the user sees the Dart wrapper
  // class. These methods need to be kept in sync.
  bool _needsConverting(Type type) =>
      type is ObjCInterface || _isObject(type) || _isInstanceType(type);

  String _getConvertedType(Type type, Writer w, String enclosingClass) {
    if (type is BooleanType) return 'bool';
    if (type is ObjCInterface) return type.name;
    if (_isObject(type)) return 'NSObject';
    if (_isInstanceType(type)) return enclosingClass;
    return type.getDartType(w);
  }

  String _doArgConversion(Type type, String value) {
    if (type is ObjCInterface || _isObject(type) || _isInstanceType(type)) {
      return '$value._id';
    }
    return value;
  }

  String _doReturnConversion(
      Type type, String value, String enclosingClass, String library) {
    if (type is ObjCInterface) return '${type.name}._($value, $library)';
    if (_isObject(type)) return 'NSObject._($value, $library)';
    if (_isInstanceType(type)) return '$enclosingClass._($value, $library)';
    return value;
  }
}

enum ObjCMethodKind {
  method,
  propertyGetter,
  propertySetter,
}

class ObjCProperty {
  final String originalName;
  String? dartName;

  ObjCProperty(this.originalName);
}

class ObjCMethod {
  final String? dartDoc;
  final String originalName;
  final ObjCProperty? property;
  Type? returnType;
  final List<ObjCMethodParam> params;
  final ObjCMethodKind kind;
  final bool isClass;
  Func? msgSend;

  ObjCMethod({
    required this.originalName,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClass,
    this.returnType,
    List<ObjCMethodParam>? params_,
  }) : params = params_ ?? [];

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;

  void addDependencies(Set<Binding> dependencies) {
    returnType ??= NativeType(SupportedNativeType.Void);
    returnType!.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }
    msgSend = _builtInFunctions.getMsgSendFunc(returnType!, params);
  }

  String _getDartMethodName(UniqueNamer uniqueNamer) {
    if (property != null) {
      // A getter and a setter are allowed to have the same name, so we can't
      // just run the name through uniqueNamer. Instead they need to share
      // the dartName, which is run through uniqueNamer.
      if (property!.dartName == null) {
        property!.dartName = uniqueNamer.makeUnique(property!.originalName);
      }
      return property!.dartName!;
    }
    // Objective C methods can look like:
    // foo
    // foo:
    // foo:someArgName:
    // If there is a trailing ':', omit it. Replace all other ':' with '_'.
    final name =
        originalName.replaceAll(RegExp(r":$"), "").replaceAll(":", "_");
    return uniqueNamer.makeUnique(name);
  }
}

class ObjCMethodParam {
  final Type type;
  final String name;
  ObjCMethodParam(this.type, this.name);
}
