// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

class ObjCInterface extends NoLookUpBinding {
  ObjCInterface? superType;
  final methods = <ObjCMethod>[];

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
    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    // TODO: Use UniqueNamer.
    // TODO: Extends.

    s.write('class $name {');
    for (final m in methods) {
      m.toBindingString(w, s);
    }
    s.write('}\n\n');

    return BindingString(type: BindingStringType.objcInterface, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    for (final m in methods) {
      m.addDependencies(dependencies);
    }
  }
}

class ObjCMethod {
  final String? dartDoc;
  final String originalName;
  final String name;
  Type? returnType;
  final params = <ObjCMethodParam>[];
  final bool propertyGetterOrSetter;
  final bool isClassMethod;

  ObjCMethod({
    String? originalName,
    required this.name,
    this.dartDoc,
    this.propertyGetterOrSetter = false,
    this.isClassMethod = false,
  }) : originalName = originalName ?? name;

  void toBindingString(Writer w, StringBuffer s) {
    s.write('  ${returnType!.getDartType(w)} $name(');
    var first = true;
    for (final p in params) {
      if (first) {
        first = false;
      } else {
        s.write(', ');
      }
      s.write('${p.type.getDartType(w)} ${p.name}');
    }
    s.write(') {\n');
    // TODO: Implementation.
    s.write('  }\n');
  }

  void addDependencies(Set<Binding> dependencies) {
    returnType!.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }
  }
}

class ObjCMethodParam {
  final Type type;
  final String name;
  ObjCMethodParam(this.type, this.name);
}
