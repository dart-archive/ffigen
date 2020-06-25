// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'func.dart' show Parameter;
import 'type.dart';
import 'writer.dart';

/// A simple typedef function for C functions, Expands to -
///
/// ```dart
/// typedef $name = $returnType Function(
///   $parameter1...,
///   $parameter2...,
///   .
///   .
/// );`
/// ```
/// Note: This doesn't bind with anything.
class TypedefC extends Binding {
  final Type returnType;
  final List<Parameter> parameters;

  TypedefC({
    @required String name,
    String dartDoc,
    @required this.returnType,
    List<Parameter> parameters,
  })  : parameters = parameters ?? [],
        super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    s.write('typedef $name = ${returnType.getCType(w)} Function(\n');
    for (final p in parameters) {
      s.write('  ${p.type.getCType(w)} ${p.name},\n');
    }
    s.write(');\n\n');

    return BindingString(type: BindingStringType.typeDef, string: s.toString());
  }
}
