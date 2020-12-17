// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'func.dart' show Parameter;
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A simple typedef, Expands to -
///
/// ```dart
/// typedef $name = $returnType Function(
///   $parameter1...,
///   $parameter2...,
///   .
///   .
/// );
/// ```
/// Return/Parameter types can be of for C/Dart signarture depending on [typedefType].
///
/// Note: re-set [name] after resolving name conflicts.
class Typedef {
  String name;
  String? dartDoc;
  final Type returnType;
  final TypedefType typedefType;
  final List<Parameter> parameters;

  Typedef({
    required this.name,
    this.dartDoc,
    required this.returnType,
    required this.typedefType,
    List<Parameter>? parameters,
  }) : parameters = parameters ?? [];

  /// Returns the [Typedef] dependencies required by this typedef including itself.
  List<Typedef> getDependencies() {
    final dep = <Typedef>[];
    for (final p in parameters) {
      final base = p.type.getBaseType();
      if (base.broadType == BroadType.NativeFunction) {
        dep.addAll(base.nativeFunc!.getDependencies());
      }
    }
    final returnTypeBase = returnType.getBaseType();
    if (returnTypeBase.broadType == BroadType.NativeFunction) {
      dep.addAll(returnTypeBase.nativeFunc!.getDependencies());
    }
    dep.add(this);
    return dep;
  }

  String toTypedefString(Writer w) {
    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    final typedefName = name;
    final paramNamer = UniqueNamer({});
    if (typedefType == TypedefType.C) {
      s.write('typedef $typedefName = ${returnType.getCType(w)} Function(\n');
      for (final p in parameters) {
        final name = p.name.isNotEmpty ? paramNamer.makeUnique(p.name) : p.name;
        s.write('  ${p.type.getCType(w)} ${name},\n');
      }
      s.write(');\n\n');
    } else {
      s.write(
          'typedef $typedefName = ${returnType.getDartType(w)} Function(\n');
      for (final p in parameters) {
        final name = p.name.isNotEmpty ? paramNamer.makeUnique(p.name) : p.name;

        s.write('  ${p.type.getDartType(w)} ${name},\n');
      }
      s.write(');\n\n');
    }

    return s.toString();
  }
}

enum TypedefType { C, Dart }
