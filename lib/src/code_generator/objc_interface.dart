// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCInterface extends LookUpBinding {
  ObjCInterface? superType;
  final classMethods = <ObjCMethod>[];
  final instanceMethods = <ObjCMethod>[];

  ObjCInterface({
    String? usr,
    String? originalName,
    required String name,
    String? dartDoc,
  })  : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

  @override
  BindingString toBindingString(Writer w) {
    // TODO: Fill in.
    return BindingString(type: BindingStringType.objcInterface, string: "TODO");
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    // TODO: Add base type and method types.
  }
}

class ObjCMethod {
  final String? dartDoc;
  final String originalName;
  final String name;
  Type? returnType;
  final bool propertyGetterOrSetter;

  ObjCMethod({
    String? originalName,
    required this.name,
    this.dartDoc,
    this.propertyGetterOrSetter = false,
  }) : originalName = originalName ?? name;
}
