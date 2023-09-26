// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

/// An ObjC type annotated with nullable.
class ObjCNullable extends Type {
  Type child;

  ObjCNullable(this.child) {
    assert(child is ObjCInterface ||
        child is ObjCBlock ||
        child is ObjCObjectPointer ||
        child is ObjCInstanceType);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    child.addDependencies(dependencies);
  }

  @override
  Type get baseType => child.baseType;

  @override
  String getCType(Writer w) => child.getCType(w);

  @override
  String getFfiDartType(Writer w) => child.getFfiDartType(w);

  @override
  String getDartType(Writer w) => '${child.getDartType(w)}?';

  @override
  String toString() => '$child?';

  @override
  String cacheKey() => '${child.cacheKey()}?';
}
