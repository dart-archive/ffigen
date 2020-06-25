// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
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
class Constant extends Binding {
  final Type type;

  /// The rawValue is pasted as it is.
  ///
  /// Put quotes if type is a string.
  final String rawValue;

  const Constant({
    @required String name,
    String dartDoc,
    @required this.type,
    @required this.rawValue,
  }) : super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    s.write('const ${type.getDartType(w)} $name = $rawValue;\n\n');

    return BindingString(
        type: BindingStringType.constant, string: s.toString());
  }
}
