// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:meta/meta.dart';

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
  String dartDoc;
  final Type returnType;
  final TypedefType typedefType;
  final List<Parameter> parameters;

  Typedef({
    @required this.name,
    this.dartDoc,
    @required this.returnType,
    @required this.typedefType,
    List<Parameter> parameters,
  }) : parameters = parameters ?? [];

  String toTypedefString(Writer w) {
    final s = StringBuffer();
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc));
    }
    final typedefName = name;

    if (typedefType == TypedefType.C) {
      s.write('typedef $typedefName = ${returnType.getCType(w)} Function(\n');
      for (final p in parameters) {
        s.write('  ${p.type.getCType(w)} ${p.name},\n');
      }
      s.write(');\n\n');
    } else {
      s.write(
          'typedef $typedefName = ${returnType.getDartType(w)} Function(\n');
      for (final p in parameters) {
        s.write('  ${p.type.getDartType(w)} ${p.name},\n');
      }
      s.write(');\n\n');
    }

    return s.toString();
  }
}

enum TypedefType { C, Dart }
