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
  'poseAsClass:',
  'resolveClassMethod:',
  'resolveInstanceMethod:',
  'setVersion:',
  'superclass',
  'version',
};

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

  final ObjCBuiltInFunctions builtInFunctions;
  late final ObjCInternalGlobal _classObject;

  ObjCInterface({
    String? usr,
    required String originalName,
    required String name,
    String? dartDoc,
    required this.builtInFunctions,
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
      stringParams.addAll(params.map((p) =>
          (_getConvertedType(p.type, w, name) +
              (p.isNullable ? "? " : " ") +
              p.name)));
      return '(' + stringParams.join(", ") + ')';
    }

    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    final uniqueNamer = UniqueNamer({name});
    final natLib = w.className;

    builtInFunctions.ensureUtilsExist(w, s);
    final objType = PointerType(objCObjectType).getCType(w);

    // Class declaration.
    s.write('class $name ');
    uniqueNamer.markUsed('_id');
    s.write('extends ${superType?.name ?? '_ObjCWrapper'} {\n');
    s.write('  $name._($objType id, $natLib lib) : super._(id, lib);\n\n');

    // Cast method.
    s.write('  static $name castFrom<T extends _ObjCWrapper>(T other) {\n');
    s.write('    return $name._(other._id, other._lib);\n');
    s.write('  }\n\n');

    s.write(
        '  static $name castFromPointer($natLib lib, ffi.Pointer<ObjCObject> other) {\n');
    s.write('    return $name._(other, lib);\n');
    s.write('  }\n\n');

    if (isNSString) {
      builtInFunctions.generateNSStringUtils(w, s);
    }

    // Methods.
    for (final m in methods) {
      final methodName = m._getDartMethodName(uniqueNamer);
      final isStatic = m.isClass;
      final returnType = m.returnType!;

      // The method declaration.
      if (m.dartDoc != null) {
        s.write(makeDartDoc(m.dartDoc!));
      }

      s.write('  ');
      if (isStatic) {
        s.write('static ');
        s.write(
            _getConvertedReturnType(returnType, w, name, m.isNullableReturn));

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
            s.write(_getConvertedReturnType(
                returnType, w, name, m.isNullableReturn));
            s.write(' $methodName');
            s.write(paramsToString(m.params, isStatic: false));
            break;
          case ObjCMethodKind.propertyGetter:
            // returnType get methodName
            s.write(_getConvertedReturnType(
                returnType, w, name, m.isNullableReturn));
            s.write(' get $methodName');
            break;
          case ObjCMethodKind.propertySetter:
            // set methodName(...)
            s.write(' set $methodName');
            s.write(paramsToString(m.params, isStatic: false));
            break;
        }
      }

      s.write(' {\n');

      // Implementation.
      final convertReturn = m.kind != ObjCMethodKind.propertySetter &&
          _needsConverting(returnType);

      if (returnType != NativeType(SupportedNativeType.Void)) {
        s.write('    ${convertReturn ? 'final _ret = ' : 'return '}');
      }
      s.write('_lib.${m.msgSend!.name}(');
      s.write(isStatic ? '_lib.${_classObject.name}' : '_id');
      s.write(', _lib.${m.selObject!.name}');
      for (final p in m.params) {
        s.write(', ${_doArgConversion(p)}');
      }
      s.write(');\n');
      if (convertReturn) {
        final result = _doReturnConversion(
            returnType, '_ret', name, '_lib', m.isNullableReturn);
        s.write('    return $result;');
      }

      s.write('  }\n\n');
    }

    s.write('}\n\n');

    if (isNSString) {
      builtInFunctions.generateStringUtils(w, s);
    }

    return BindingString(
        type: BindingStringType.objcInterface, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
    builtInFunctions.addDependencies(dependencies);

    _classObject = ObjCInternalGlobal(
        PointerType(objCObjectType),
        '_class_$originalName',
        () => '${builtInFunctions.getClass.name}("$originalName")')
      ..addDependencies(dependencies);

    if (isNSString) {
      _addNSStringMethods();
    }

    _filterPropertyMethods();

    if (superType != null) {
      superType!.addDependencies(dependencies);
      _copyClassMethodsFromSuperType();
    }

    for (final m in methods) {
      m.addDependencies(dependencies, builtInFunctions);
    }
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
      kind: ObjCMethodKind.propertyGetter,
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
      type is ObjCInterface ||
      type is ObjCBlock ||
      _isObject(type) ||
      _isInstanceType(type);

  String _getConvertedType(Type type, Writer w, String enclosingClass) {
    if (type is BooleanType) return 'bool';
    if (type is ObjCInterface) return type.name;
    if (type is ObjCBlock) return type.name;
    if (_isObject(type)) return 'NSObject';
    if (_isInstanceType(type)) return enclosingClass;
    return type.getDartType(w);
  }

  String _getConvertedReturnType(
      Type type, Writer w, String enclosingClass, bool isNullableReturn) {
    final result = _getConvertedType(type, w, enclosingClass);
    if (isNullableReturn) {
      return result + "?";
    }
    return result;
  }

  String _doArgConversion(ObjCMethodParam arg) {
    if (arg.type is ObjCInterface ||
        _isObject(arg.type) ||
        _isInstanceType(arg.type) ||
        arg.type is ObjCBlock) {
      final field = arg.type is ObjCBlock ? '_impl' : '_id';
      if (arg.isNullable) {
        return '${arg.name}?.$field ?? ffi.nullptr';
      } else {
        return '${arg.name}.$field';
      }
    }
    return arg.name;
  }

  String _doReturnConversion(Type type, String value, String enclosingClass,
      String library, bool isNullable) {
    String prefix = "";
    if (isNullable) {
      prefix += "$value.address == 0 ? null : ";
    }
    if (type is ObjCInterface) {
      return prefix + '${type.name}._($value, $library)';
    }
    if (type is ObjCBlock) {
      return prefix + '${type.name}._($value, $library)';
    }
    if (_isObject(type)) {
      return prefix + 'NSObject._($value, $library)';
    }
    if (_isInstanceType(type)) {
      return prefix + '$enclosingClass._($value, $library)';
    }
    return prefix + value;
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
  final bool isNullableReturn;
  final List<ObjCMethodParam> params;
  final ObjCMethodKind kind;
  final bool isClass;
  ObjCInternalGlobal? selObject;
  Func? msgSend;

  ObjCMethod({
    required this.originalName,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClass,
    this.returnType,
    this.isNullableReturn = false,
    List<ObjCMethodParam>? params_,
  }) : params = params_ ?? [];

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;

  void addDependencies(
      Set<Binding> dependencies, ObjCBuiltInFunctions builtInFunctions) {
    returnType ??= NativeType(SupportedNativeType.Void);
    returnType!.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }
    selObject ??= builtInFunctions.getSelObject(originalName)
      ..addDependencies(dependencies);
    msgSend ??= builtInFunctions.getMsgSendFunc(returnType!, params)
      ..addDependencies(dependencies);
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
  final bool isNullable;
  ObjCMethodParam(this.type, this.name, {this.isNullable = false});
}
