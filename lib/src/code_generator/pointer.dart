// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

/// Represents a pointer.
class PointerType extends Type {
  final Type child;
  PointerType(this.child);

  @override
  void addDependencies(Set<Binding> dependencies) {
    child.addDependencies(dependencies);
  }

  @override
  Type get baseType => child.baseType;

  @override
  String getCType(Writer w) =>
      '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';

  @override
  String toString() => '$child*';

  @override
  String cacheKey() => '${child.cacheKey()}*';
}

/// Represents a constant array, which has a fixed size.
class ConstantArray extends PointerType {
  final int length;
  ConstantArray(this.length, Type child) : super(child);

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
  IncompleteArray(Type child) : super(child);

  @override
  Type get baseArrayType => child.baseArrayType;

  @override
  String toString() => '$child[]';

  @override
  String cacheKey() => '${child.cacheKey()}[]';
}
