// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

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
  final bool _useDartType;

  factory Typealias({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required Type type,

    /// If true, the binding string uses Dart type instead of C type.
    ///
    /// E.g if C type is ffi.Void func(ffi.Int32), Dart type is void func(int).
    bool useDartType = false,
    bool isInternal = false,
  }) {
    final funcType = _getFunctionTypeFromPointer(type);
    if (funcType != null) {
      type = PointerType(NativeFunc(Typealias._(
        name: '${name}_function',
        type: funcType,
        useDartType: useDartType,
        isInternal: isInternal,
      )));
    }
    return Typealias._(
      usr: usr,
      originalName: originalName,
      dartDoc: dartDoc,
      name: name,
      type: type,
      useDartType: useDartType,
      isInternal: isInternal,
    );
  }

  Typealias._({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required this.type,
    bool useDartType = false,
    bool isInternal = false,
  })  : _useDartType = useDartType,
        super(
          usr: usr,
          name: name,
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
    final sb = StringBuffer();
    if (dartDoc != null) {
      sb.write(makeDartDoc(dartDoc!));
    }
    sb.write('typedef $name = ');
    sb.write('${_useDartType ? type.getDartType(w) : type.getCType(w)};\n');
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
  String getDartType(Writer w) {
    // Typealias cannot be used by name in Dart types unless both the C and Dart
    // type of the underlying types are same.
    if (sameDartAndCType(type, w)) {
      return name;
    } else {
      return type.getDartType(w);
    }
  }

  @override
  String cacheKey() => type.cacheKey();

  @override
  String? getDefaultValue(Writer w, String nativeLib) =>
      type.getDefaultValue(w, nativeLib);
}
