// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

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

final _logger = Logger('ffigen.code_generator.objc_interface');

class ObjCInterface extends BindingType {
  ObjCInterface? superType;
  final methods = <String, ObjCMethod>{};
  bool filled = false;

  final String lookupName;
  final ObjCBuiltInFunctions builtInFunctions;
  late final ObjCInternalGlobal _classObject;
  late final ObjCInternalGlobal _isKindOfClass;
  late final ObjCMsgSendFunc _isKindOfClassMsgSend;

  ObjCInterface({
    super.usr,
    required String super.originalName,
    String? name,
    String? lookupName,
    super.dartDoc,
    required this.builtInFunctions,
  })  : lookupName = lookupName ?? originalName,
        super(
          name: name ?? originalName,
        ) {
    builtInFunctions.registerInterface(this);
  }

  bool get isNSString => originalName == "NSString";
  bool get isNSData => originalName == "NSData";

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
      return '(${stringParams.join(", ")})';
    }

    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    final uniqueNamer = UniqueNamer({name, '_id', '_lib'});
    final natLib = w.className;

    builtInFunctions.ensureUtilsExist(w, s);
    final objType = PointerType(objCObjectType).getCType(w);

    // Class declaration.
    s.write('''
class $name extends ${superType?.name ?? '_ObjCWrapper'} {
  $name._($objType id, $natLib lib,
      {bool retain = false, bool release = false}) :
          super._(id, lib, retain: retain, release: release);

  /// Returns a [$name] that points to the same underlying object as [other].
  static $name castFrom<T extends _ObjCWrapper>(T other) {
    return $name._(other._id, other._lib, retain: true, release: true);
  }

  /// Returns a [$name] that wraps the given raw object pointer.
  static $name castFromPointer($natLib lib, $objType other,
      {bool retain = false, bool release = false}) {
    return $name._(other, lib, retain: retain, release: release);
  }

  /// Returns whether [obj] is an instance of [$name].
  static bool isInstance(_ObjCWrapper obj) {
    return obj._lib.${_isKindOfClassMsgSend.name}(
        obj._id, obj._lib.${_isKindOfClass.name},
        obj._lib.${_classObject.name});
  }

''');

    if (isNSString) {
      builtInFunctions.generateNSStringUtils(w, s);
    }

    // Methods.
    for (final m in methods.values) {
      final methodName = m._getDartMethodName(uniqueNamer);
      final isStatic = m.isClass;
      final isStret = m.msgSend!.isStret;

      var returnType = m.returnType;
      var params = m.params;
      if (isStret) {
        params = [ObjCMethodParam(PointerType(returnType), 'stret'), ...params];
        returnType = voidType;
      }

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
        s.write(paramsToString(params, isStatic: true));
      } else {
        if (superType?.methods[m.originalName]?.sameAs(m) ?? false) {
          s.write('@override\n  ');
        }
        switch (m.kind) {
          case ObjCMethodKind.method:
            // returnType methodName(...)
            s.write(_getConvertedType(returnType, w, name));
            s.write(' $methodName');
            s.write(paramsToString(params, isStatic: false));
            break;
          case ObjCMethodKind.propertyGetter:
            s.write(_getConvertedType(returnType, w, name));
            if (isStret) {
              // void getMethodName(Pointer<returnType> stret, NativeLibrary _lib)
              s.write(' get');
              s.write(methodName[0].toUpperCase() + methodName.substring(1));
              s.write(paramsToString(params, isStatic: false));
            } else {
              // returnType get methodName
              s.write(' get $methodName');
            }
            break;
          case ObjCMethodKind.propertySetter:
            // set methodName(...)
            s.write(' set $methodName');
            s.write(paramsToString(params, isStatic: false));
            break;
        }
      }

      s.write(' {\n');

      // Implementation.
      final convertReturn = m.kind != ObjCMethodKind.propertySetter &&
          _needsConverting(returnType);

      if (returnType != voidType) {
        s.write('    ${convertReturn ? 'final _ret = ' : 'return '}');
      }
      s.write('_lib.${m.msgSend!.name}(');
      if (isStret) {
        s.write('stret, ');
      }
      s.write(isStatic ? '_lib.${_classObject.name}' : '_id');
      s.write(', _lib.${m.selObject!.name}');
      for (final p in m.params) {
        final convertedParam =
            p.type.convertDartTypeToFfiDartType(w, p.name, objCRetain: false);
        s.write(', $convertedParam');
      }
      s.write(');\n');
      if (convertReturn) {
        final result = returnType.convertFfiDartTypeToDartType(
          w,
          '_ret',
          '_lib',
          objCRetain: !m.isOwnedReturn,
          objCEnclosingClass: name,
        );
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
        '_class_$originalName',
        (Writer w) => '${builtInFunctions.getClass.name}("$lookupName")',
        builtInFunctions.getClass)
      ..addDependencies(dependencies);
    _isKindOfClass = builtInFunctions.getSelObject('isKindOfClass:');
    _isKindOfClassMsgSend = builtInFunctions.getMsgSendFunc(
        BooleanType(), [ObjCMethodParam(PointerType(objCObjectType), 'clazz')]);

    if (isNSString) {
      _addNSStringMethods();
    }

    if (isNSData) {
      _addNSDataMethods();
    }

    if (superType != null) {
      superType!.addDependencies(dependencies);
      _copyMethodsFromSuperType();
      _fixNullabilityOfOverriddenMethods();
    }

    for (final m in methods.values) {
      m.addDependencies(dependencies, builtInFunctions);
    }
  }

  void _copyMethodsFromSuperType() {
    // We need to copy certain methods from the super type:
    //  - Class methods, because Dart classes don't inherit static methods.
    //  - Methods that return instancetype, because the subclass's copy of the
    //    method needs to return the subclass, not the super class.
    //    Note: instancetype is only allowed as a return type, not an arg type.
    for (final m in superType!.methods.values) {
      if (m.isClass &&
          !_excludedNSObjectClassMethods.contains(m.originalName)) {
        addMethod(m);
      } else if (_isInstanceType(m.returnType)) {
        addMethod(m);
      }
    }
  }

  void _fixNullabilityOfOverriddenMethods() {
    // ObjC ignores nullability when deciding if an override for an inherited
    // method is valid. But in Dart it's invalid to override a method and change
    // it's return type from non-null to nullable, or its arg type from nullable
    // to non-null. So in these cases we have to make the non-null type
    // nullable, to avoid Dart compile errors.
    var superType_ = superType;
    while (superType_ != null) {
      for (final method in methods.values) {
        final superMethod = superType_.methods[method.originalName];
        if (superMethod != null && !superMethod.isClass && !method.isClass) {
          if (superMethod.returnType.typealiasType is! ObjCNullable &&
              method.returnType.typealiasType is ObjCNullable) {
            superMethod.returnType = ObjCNullable(superMethod.returnType);
          }
          final numArgs = method.params.length < superMethod.params.length
              ? method.params.length
              : superMethod.params.length;
          for (int i = 0; i < numArgs; ++i) {
            final param = method.params[i];
            final superParam = superMethod.params[i];
            if (superParam.type.typealiasType is ObjCNullable &&
                param.type.typealiasType is! ObjCNullable) {
              param.type = ObjCNullable(param.type);
            }
          }
        }
      }
      superType_ = superType_.superType;
    }
  }

  static bool _isInstanceType(Type type) {
    if (type is ObjCInstanceType) return true;
    final baseType = type.typealiasType;
    return baseType is ObjCNullable && baseType.child is ObjCInstanceType;
  }

  void addMethod(ObjCMethod method) {
    final oldMethod = methods[method.originalName];
    if (oldMethod != null) {
      // Typically we ignore duplicate methods. However, property setters and
      // getters are duplicated in the AST. One copy is marked with
      // ObjCMethodKind.propertyGetter/Setter. The other copy is missing
      // important information, and is a plain old instanceMethod. So if the
      // existing method is an instanceMethod, and the new one is a property,
      // override it.
      if (method.isProperty && !oldMethod.isProperty) {
        // Fallthrough.
      } else if (!method.isProperty && oldMethod.isProperty) {
        // Don't override, but also skip the same method check below.
        return;
      } else {
        // Check duplicate is the same method.
        if (!method.sameAs(oldMethod)) {
          _logger.severe('Duplicate methods with different signatures: '
              '$originalName.${method.originalName}');
        }
        return;
      }
    }
    methods[method.originalName] = method;
  }

  void _addNSStringMethods() {
    addMethod(ObjCMethod(
      originalName: 'stringWithCharacters:length:',
      kind: ObjCMethodKind.method,
      isClass: true,
      returnType: this,
      params_: [
        ObjCMethodParam(PointerType(wCharType), 'characters'),
        ObjCMethodParam(unsignedIntType, 'length'),
      ],
    ));
    addMethod(ObjCMethod(
      originalName: 'dataUsingEncoding:',
      kind: ObjCMethodKind.method,
      isClass: false,
      returnType: builtInFunctions.nsData,
      params_: [
        ObjCMethodParam(unsignedIntType, 'encoding'),
      ],
    ));
    addMethod(ObjCMethod(
      originalName: 'length',
      kind: ObjCMethodKind.propertyGetter,
      isClass: false,
      returnType: unsignedIntType,
      params_: [],
    ));
  }

  void _addNSDataMethods() {
    addMethod(ObjCMethod(
      originalName: 'bytes',
      kind: ObjCMethodKind.propertyGetter,
      isClass: false,
      returnType: PointerType(voidType),
      params_: [],
    ));
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);

  @override
  String getDartType(Writer w) => name;

  @override
  bool get sameFfiDartAndCType => true;

  @override
  bool get sameDartAndCType => false;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
  }) =>
      ObjCInterface.generateGetId(value, objCRetain);

  static String generateGetId(String value, bool objCRetain) =>
      objCRetain ? '$value._retainAndReturnId()' : '$value._id';

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value,
    String library, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      ObjCInterface.generateConstructor(name, value, library, objCRetain);

  static String generateConstructor(
    String className,
    String value,
    String library,
    bool objCRetain,
  ) {
    final ownershipFlags = 'retain: $objCRetain, release: true';
    return '$className._($value, $library, $ownershipFlags)';
  }

  // Utils for converting between the internal types passed to native code, and
  // the external types visible to the user. For example, ObjCInterfaces are
  // passed to native as Pointer<ObjCObject>, but the user sees the Dart wrapper
  // class. These methods need to be kept in sync.
  bool _needsConverting(Type type) =>
      type is ObjCInstanceType ||
      type.typealiasType is ObjCInterface ||
      type.typealiasType is ObjCBlock ||
      type.typealiasType is ObjCObjectPointer ||
      type.typealiasType is ObjCNullable;

  String _getConvertedType(Type type, Writer w, String enclosingClass) {
    if (type is ObjCInstanceType) return enclosingClass;
    final baseType = type.typealiasType;
    if (baseType is ObjCNullable && baseType.child is ObjCInstanceType) {
      return '$enclosingClass?';
    }
    return type.getDartType(w);
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
  Type returnType;
  final List<ObjCMethodParam> params;
  final ObjCMethodKind kind;
  final bool isClass;
  bool returnsRetained = false;
  ObjCInternalGlobal? selObject;
  ObjCMsgSendFunc? msgSend;

  ObjCMethod({
    required this.originalName,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClass,
    required this.returnType,
    List<ObjCMethodParam>? params_,
  }) : params = params_ ?? [];

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;

  void addDependencies(
      Set<Binding> dependencies, ObjCBuiltInFunctions builtInFunctions) {
    returnType.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }
    selObject ??= builtInFunctions.getSelObject(originalName)
      ..addDependencies(dependencies);
    msgSend ??= builtInFunctions.getMsgSendFunc(returnType, params)
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
    // So replace all ':' with '_'.
    return uniqueNamer.makeUnique(originalName.replaceAll(":", "_"));
  }

  bool sameAs(ObjCMethod other) {
    if (originalName != other.originalName) return false;
    if (kind != other.kind) return false;
    if (isClass != other.isClass) return false;
    // msgSend is deduped by signature, so this check covers the signature.
    return msgSend == other.msgSend;
  }

  static final _copyRegExp = RegExp('[cC]opy');
  bool get isOwnedReturn =>
      returnsRetained ||
      originalName.startsWith('new') ||
      originalName.startsWith('alloc') ||
      originalName.contains(_copyRegExp);

  @override
  String toString() => '$returnType $originalName(${params.join(', ')})';
}

class ObjCMethodParam {
  Type type;
  final String name;
  ObjCMethodParam(this.type, this.name);

  @override
  String toString() => '$type $name';
}
