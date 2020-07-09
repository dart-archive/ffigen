// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/typedef.dart';
import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A simple Constant.
///
/// Expands to -
/// ```dart
/// const <type> <name> = <rawValue>;
/// ```
///
/// Example -
/// ```dart
/// const int name = 10;
/// ```
class Constant extends NoLookUpBinding {
  final Type type;

  /// The rawValue is pasted as it is.
  ///
  /// Put quotes if type is a string.
  final String rawValue;

  Constant({
    @required String name,
    String dartDoc,
    @required this.type,
    @required this.rawValue,
  }) : super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final constantName = name;

    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc));
    }

    s.write('const ${type.getDartType(w)} $constantName = $rawValue;\n\n');

    return BindingString(
        type: BindingStringType.constant, string: s.toString());
  }

  @override
  List<Typedef> getTypedefDependencies(Writer w) => const [];
}
