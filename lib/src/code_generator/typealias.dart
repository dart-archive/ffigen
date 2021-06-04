// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A simple Typealias, Expands to -
///
/// ```dart
/// typedef $name = $type;
/// );
/// ```
class Typealias extends NoLookUpBinding {
  final Type type;
  final bool _useDartType;

  Typealias({
    String? usr,
    String? originalName,
    String? dartDoc,
    required String name,
    required this.type,

    /// If true, the binding string uses Dart type instead of C type.
    ///
    /// E.g if C type is ffi.Void func(ffi.Int32), Dart type is void func(int).
    bool useDartType = false,
  })  : _useDartType = useDartType,
        super(
          usr: usr,
          name: name,
          dartDoc: dartDoc,
          originalName: originalName,
        );

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    type.addDependencies(dependencies);
  }

  @override
  BindingString toBindingString(Writer w) {
    final sb = StringBuffer();
    if (dartDoc != null) {
      sb.write(makeDartDoc(dartDoc!));
    }
    sb.write(
        'typedef $name = ${_useDartType ? type.getDartType(w) : type.getCType(w)};\n');
    return BindingString(
        type: BindingStringType.typeDef, string: sb.toString());
  }
}
