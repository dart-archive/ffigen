// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

/// Represents a pointer.
class PointerType extends Type {
  final Type child;

  PointerType._(this.child);

  factory PointerType(Type child) {
    if (child == objCObjectType) {
      return ObjCObjectPointer();
    }
    return PointerType._(child);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    child.addDependencies(dependencies);
  }

  @override
  Type get baseType => child.baseType;

  @override
  String getCType(Writer w) =>
      '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';

  // Both the C type and the FFI Dart type are 'Pointer<$cType>'.
  @override
  bool get sameFfiDartAndCType => true;

  @override
  String toString() => '$child*';

  @override
  String cacheKey() => '${child.cacheKey()}*';
}

/// Represents a constant array, which has a fixed size.
class ConstantArray extends PointerType {
  final int length;
  ConstantArray(this.length, Type child) : super._(child);

  @override
  Type get baseArrayType => child.baseArrayType;

  @override
  bool get isIncompleteCompound => baseArrayType.isIncompleteCompound;

  @override
  String toString() => '$child[$length]';

  @override
  String cacheKey() => '${child.cacheKey()}[$length]';
}

/// Represents an incomplete array, which has an unknown size.
class IncompleteArray extends PointerType {
  IncompleteArray(super.child) : super._();

  @override
  Type get baseArrayType => child.baseArrayType;

  @override
  String toString() => '$child[]';

  @override
  String cacheKey() => '${child.cacheKey()}[]';
}

/// A pointer to an NSObject.
class ObjCObjectPointer extends PointerType {
  factory ObjCObjectPointer() => _inst;

  static final _inst = ObjCObjectPointer._();
  ObjCObjectPointer._() : super._(objCObjectType);

  @override
  String getDartType(Writer w) => 'NSObject';

  @override
  bool get sameDartAndCType => false;

  @override
  bool get sameDartAndFfiDartType => false;

  @override
  String convertDartTypeToFfiDartType(
    Writer w,
    String value, {
    required bool objCRetain,
  }) =>
      ObjCInterface.generateGetId(value, objCRetain);

  @override
  String convertFfiDartTypeToDartType(
    Writer w,
    String value,
    String library, {
    required bool objCRetain,
    String? objCEnclosingClass,
  }) =>
      ObjCInterface.generateConstructor('NSObject', value, library, objCRetain);
}
