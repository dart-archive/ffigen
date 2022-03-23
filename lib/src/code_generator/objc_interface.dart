// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'imports.dart';
import 'writer.dart';

class _ObjCBuiltInFunctions {
  late final _registerNameFunc = Func(
    name: 'sel_registerName',
    returnType: Type.pointer(Type.struct(objCSelType)),
    parameters: [
      Parameter(name: 'str', type: Type.pointer(Type.importedType(charType)))
    ],
  );
  late final String registerName;

  late final _getClassFunc = Func(
    name: 'objc_getClass',
    returnType: Type.pointer(Type.struct(objCObjectType)),
    parameters: [
      Parameter(name: 'str', type: Type.pointer(Type.importedType(charType)))
    ],
  );
  late final String getClass;

  // We need to load a separate instance of objc_msgSend for each signature.
  final _msgSendFuncs = <String, Func>{};
  Func getMsgSendFunc(Type returnType, List<ObjCMethodParam> params) {
    // TODO: These keys don't dedupe sufficiently.
    var key = returnType.hashCode.toRadixString(36);
    for (final p in params) key += ' ' + p.type.hashCode.toRadixString(36);
    _msgSendFuncs[key] ??= Func(
      name: 'objc_msgSend_${_msgSendFuncs.length}',
      originalName: 'objc_msgSend',
      returnType: returnType,
      parameters: [
        Parameter(name: 'obj', type: Type.pointer(Type.struct(objCObjectType))),
        Parameter(name: 'sel', type: Type.pointer(Type.struct(objCSelType))),
        for (final p in params) Parameter(name: p.name, type: p.type),
      ],
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
    s.write('  pkg_ffi.calloc.free(cstr);\n');
    s.write('  return sel;\n');
    s.write('}\n');

    getClass = w.topLevelUniqueNamer.makeUnique('_getClass');
    final objType = _getClassFunc.functionType.returnType.getCType(w);
    s.write('\n$objType $getClass(${w.className} _lib, String name) {\n');
    s.write('  final cstr = name.toNativeUtf8();\n');
    s.write('  final clazz = _lib.${_getClassFunc.name}(cstr.cast());\n');
    s.write('  pkg_ffi.calloc.free(cstr);\n');
    s.write('  return clazz;\n');
    s.write('}\n');
  }

  void addDependencies(Set<Binding> dependencies) {
    _registerNameFunc.addDependencies(dependencies);
    _getClassFunc.addDependencies(dependencies);
    for (final func in _msgSendFuncs.values) func.addDependencies(dependencies);
  }
}

final _builtInFunctions = _ObjCBuiltInFunctions();

class ObjCInterface extends NoLookUpBinding {
  ObjCInterface? superType;
  final methods = <ObjCMethod>[];

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

  @override
  BindingString toBindingString(Writer w) {
    // TODO: Print dartdoc.
    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    final uniqueNamer = UniqueNamer({name});
    final natLib = w.className;

    _builtInFunctions.ensureUtilsExist(w, s);
    final objType = Type.pointer(Type.struct(objCObjectType)).getCType(w);
    final selType = Type.pointer(Type.struct(objCSelType)).getCType(w);

    // Class declaration.
    s.write('class $name ');
    uniqueNamer.markUsed('_id');
    if (superType != null) {
      s.write('extends ${superType!.name} {\n');
      s.write('  $name._($objType id, $natLib lib) : super._(id, lib);\n\n');
    } else {
      // Every class needs its id. If it has a super type, it will get it from
      // there, otherwise we need to insert it here. It also needs a reference
      // to the native library.
      s.write('{\n');
      s.write('  final $objType _id;\n');
      s.write('  final $natLib _lib;\n\n');
      s.write('  $name._(this._id, this._lib);\n\n');
    }

    // Class object, used to call static methods.
    final classObject = uniqueNamer.makeUnique('_class');
    s.write('  static $objType? $classObject;\n\n');

    // Methods.
    for (final m in methods) {
      final name = m._getDartMethodName(uniqueNamer);
      final selName = uniqueNamer.makeUnique('_sel_$name');
      final isStatic = m.kind == ObjCMethodKind.classMethod;

      // SEL object for the method.
      s.write('  static $selType? $selName;');

      // The method declaration.
      s.write('  ');
      if (isStatic) s.write('static ');
      s.write('${m.returnType!.getDartType(w)} ');
      if (m.kind == ObjCMethodKind.propertyGetter) s.write('get ');
      if (m.kind == ObjCMethodKind.propertySetter) s.write('set ');
      s.write('$name');
      if (m.kind != ObjCMethodKind.propertyGetter) {
        s.write('(');
        var first = true;
        if (isStatic) {
          first = false;
          s.write('$natLib _lib');
        }
        for (final p in m.params) {
          if (first) {
            first = false;
          } else {
            s.write(', ');
          }
          s.write('${p.type.getDartType(w)} ${p.name}');
        }
        s.write(')');
      }
      s.write(' {\n');

      // Implementation.
      if (isStatic) {
        s.write('    $classObject ??= '
            '${_builtInFunctions.getClass}(_lib, "$originalName");\n');
      }
      s.write('    $selName ??= '
          '${_builtInFunctions.registerName}(_lib, "${m.originalName}");\n');
      s.write('    return _lib.${m.msgSend!.name}(');
      s.write(isStatic ? '_class!' : '_id');
      s.write(', $selName!');
      for (final p in m.params) s.write(', ${p.name}');
      s.write(');\n');

      s.write('  }\n\n');
    }

    s.write('}\n\n');

    return BindingString(
        type: BindingStringType.objcInterface, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);

    if (superType != null) {
      superType!.addDependencies(dependencies);
      for (final m in superType!.classMethods.values) addMethod(m);
    }

    for (final m in methods) {
      m.addDependencies(dependencies);
    }

    _builtInFunctions.addDependencies(dependencies);
  }

  void addMethod(ObjCMethod method) {
    methods.add(method);
    if (method.kind == ObjCMethodKind.classMethod) {
      classMethods[method.originalName] ??= method;
    }
  }
}

enum ObjCMethodKind {
  instanceMethod,
  classMethod,
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
  final params = <ObjCMethodParam>[];
  final ObjCMethodKind kind;
  Func? msgSend;

  ObjCMethod({
    required this.originalName,
    this.property,
    this.dartDoc,
    required this.kind,
  });

  void addDependencies(Set<Binding> dependencies) {
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
    var name = originalName;
    final index = name.indexOf(':');
    if (index != -1) name = name.substring(0, index);
    return uniqueNamer.makeUnique(name.replaceAll(':', '_'));
  }
}

class ObjCMethodParam {
  final Type type;
  final String name;
  ObjCMethodParam(this.type, this.name);
}