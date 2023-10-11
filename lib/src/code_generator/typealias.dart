// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import '../strings.dart' as strings;
import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

/// A simple Typealias, Expands to -
///
/// ```dart
/// typedef $name = $type;
/// );
/// ```
class Typealias extends BindingType {
  final Type type;
  String? _ffiDartAliasName;
  String? _dartAliasName;

  /// Creates a Typealias.
  ///
  /// If [genFfiDartType] is true, a binding is generated for the Ffi Dart type
  /// in addition to the C type. See [Type.getFfiDartType].
  factory Typealias({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required Type type,
    bool genFfiDartType = false,
    bool isInternal = false,
  }) {
    final funcType = _getFunctionTypeFromPointer(type);
    if (funcType != null) {
      type = PointerType(NativeFunc(Typealias._(
        name: '${name}Function',
        type: funcType,
        genFfiDartType: genFfiDartType,
        isInternal: isInternal,
      )));
    }
    if ((originalName ?? name) == strings.objcInstanceType &&
        type is ObjCObjectPointer) {
      return ObjCInstanceType._(
        usr: usr,
        originalName: originalName,
        dartDoc: dartDoc,
        name: name,
        type: type,
        genFfiDartType: genFfiDartType,
        isInternal: isInternal,
      );
    }
    return Typealias._(
      usr: usr,
      originalName: originalName,
      dartDoc: dartDoc,
      name: name,
      type: type,
      genFfiDartType: genFfiDartType,
      isInternal: isInternal,
    );
  }

  Typealias._({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required this.type,
    bool genFfiDartType = false,
    bool isInternal = false,
  })  : _ffiDartAliasName = genFfiDartType ? 'Dart$name' : null,
        _dartAliasName =
            (!genFfiDartType && type is! Typealias && !type.sameDartAndCType)
                ? 'Dart$name'
                : null,
        super(
          usr: usr,
          name: genFfiDartType ? 'Native$name' : name,
          dartDoc: dartDoc,
          originalName: originalName,
          isInternal: isInternal,
        );

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    type.addDependencies(dependencies);
  }

  static FunctionType? _getFunctionTypeFromPointer(Type type) {
    if (type is! PointerType) return null;
    final pointee = type.child;
    if (pointee is! NativeFunc) return null;
    return pointee.type;
  }

  @override
  BindingString toBindingString(Writer w) {
    if (_ffiDartAliasName != null) {
      _ffiDartAliasName = w.topLevelUniqueNamer.makeUnique(_ffiDartAliasName!);
    }
    if (_dartAliasName != null) {
      _dartAliasName = w.topLevelUniqueNamer.makeUnique(_dartAliasName!);
    }

    final sb = StringBuffer();
    if (dartDoc != null) {
      sb.write(makeDartDoc(dartDoc!));
    }
    sb.write('typedef $name = ${type.getCType(w)};\n');
    if (_ffiDartAliasName != null) {
      sb.write('typedef $_ffiDartAliasName = ${type.getFfiDartType(w)};\n');
    }
    if (_dartAliasName != null) {
      sb.write('typedef $_dartAliasName = ${type.getDartType(w)};\n');
    }
    return BindingString(
        type: BindingStringType.typeDef, string: sb.toString());
  }

  @override
  Type get typealiasType => type.typealiasType;

  @override
  bool get isIncompleteCompound => type.isIncompleteCompound;

  @override
  String getCType(Writer w) => name;

  @override
  String getFfiDartType(Writer w) {
    if (_ffiDartAliasName != null) {
      return _ffiDartAliasName!;
    } else if (type.sameFfiDartAndCType) {
      return name;
    } else {
      return type.getFfiDartType(w);
    }
  }

  @override
  String getDartType(Writer w) => _dartAliasName ?? type.getDartType(w);

  @override
  bool get sameFfiDartAndCType => type.sameFfiDartAndCType;

  @override
  bool get sameDartAndCType => type.sameDartAndCType;

  @override
  String cacheKey() => type.cacheKey();

  @override
  String? getDefaultValue(Writer w, String nativeLib) =>
      type.getDefaultValue(w, nativeLib);
}

/// Objective C's instancetype.
///
/// This is an alias for an NSObject* that is special cased in code generation.
/// It's only valid as the return type of a method, and always appears as the
/// enclosing class's type, even in inherited methods.
class ObjCInstanceType extends Typealias {
  ObjCInstanceType._({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required Type type,
    bool genFfiDartType = false,
    bool isInternal = false,
  }) : super._(
          usr: usr,
          originalName: originalName,
          dartDoc: dartDoc,
          name: name,
          type: type,
          genFfiDartType: genFfiDartType,
          isInternal: isInternal,
        );
}
