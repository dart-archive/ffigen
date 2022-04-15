// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCBlock extends BindingType {
  ObjCBlock();

  String get cacheKey {
  }

  @override
  BindingString toBindingString(Writer w) {
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);
}
