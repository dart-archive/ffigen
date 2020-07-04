// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

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
/// );
/// ```
/// Used for generating typedefs for `Pointer<NativeFunction>`.
///
/// Name conflict resolution must be done before using.
class TypedefC {
  String name;
  String dartDoc;
  final Type returnType;
  final List<Parameter> parameters;

  TypedefC({
    @required this.name,
    this.dartDoc,
    @required this.returnType,
    List<Parameter> parameters,
  }) : parameters = parameters ?? [];

  String toTypedefString(Writer w) {
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

    return s.toString();
  }
}
