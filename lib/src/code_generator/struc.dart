// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'writer.dart';

/// A binding for C Struct.
///
/// For a C structure -
/// ```c
/// struct C {
///   int a;
///   double b;
///   int c;
/// };
/// ```
/// The generated dart code is -
/// ```dart
/// class Struct extends ffi.Struct{
///  @ffi.Int32()
///  int a;
///
///  @ffi.Double()
///  double b;
///
///  @ffi.Uint8()
///  int c;
///
/// }
/// ```
class Struc extends Binding {
  final List<Member> members;

  Struc({
    @required String name,
    String dartDoc,
    List<Member> members,
  })  : members = members ?? [],
        super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    final helpers = <ArrayHelper>[];

    // Write class declaration.
    s.write('class $name extends ${w.ffiLibraryPrefix}.Struct{\n');
    for (final m in members) {
      if (m.type.broadType == BroadType.ConstantArray) {
        // TODO(5): Remove array helpers when inline array support arives.
        final arrayHelper = ArrayHelper(
          helperClassName: '_ArrayHelper_${name}_${m.name}',
          elementType: m.type.elementType,
          length: 3,
          name: m.name,
          structName: name,
          elementNamePrefix: '_${m.name}_item_',
        );
        s.write(arrayHelper.declarationString(w));
        helpers.add(arrayHelper);
      } else {
        if (m.type.isPrimitive) {
          s.write('  @${m.type.getCType(w)}()\n');
        }
        s.write('  ${m.type.getDartType(w)} ${m.name};\n\n');
      }
    }
    s.write('}\n\n');

    for (final helper in helpers) {
      s.write(helper.helperClassString(w));
    }

    return BindingString(type: BindingStringType.struc, string: s.toString());
  }
}

class Member {
  final String name;
  final Type type;

  const Member({this.name, this.type});
}

// Helper bindings for struct array.
class ArrayHelper {
  final Type elementType;
  final int length;
  final String structName;

  final String name;
  final String helperClassName;
  final String elementNamePrefix;

  ArrayHelper({
    @required this.elementType,
    @required this.length,
    @required this.structName,
    @required this.name,
    @required this.helperClassName,
    @required this.elementNamePrefix,
  });

  /// Create declaration binding, added inside the struct binding.
  String declarationString(Writer w) {
    final s = StringBuffer();
    final arrayDartType = elementType.getDartType(w);
    final arrayCType = elementType.getCType(w);

    for (var i = 0; i < length; i++) {
      if (elementType.isPrimitive) {
        s.write('  @${arrayCType}()\n');
      }
      s.write('  ${arrayDartType} ${elementNamePrefix}$i;\n');
    }

    s.write('/// helper for array, supports `[]` operator\n');
    s.write(
        '$helperClassName get $name => ${helperClassName}(this, $length);\n');

    return s.toString();
  }

  /// Creates an array helper binding for struct array.
  String helperClassString(Writer w) {
    final s = StringBuffer();

    final arrayType = elementType.getDartType(w);

    s.write('/// Helper for array $name in struct $structName\n');

    // Write class declaration.
    s.write('class $helperClassName{\n');
    s.write('final $structName _struct;\n');
    s.write('final int length;\n');
    s.write('$helperClassName(this._struct, this.length);\n');

    // Override []= operator.
    s.write('void operator []=(int index, $arrayType value) {\n');
    s.write('switch(index) {\n');
    for (var i = 0; i < length; i++) {
      s.write('case $i:\n');
      s.write('  _struct.${elementNamePrefix}$i = value;\n');
      s.write('  break;\n');
    }
    s.write('default:\n');
    s.write(
        "  throw RangeError('Index \$index must be in the range [0..${length - 1}].');");
    s.write('}\n');
    s.write('}\n');

    // Override [] operator.
    s.write('$arrayType operator [](int index) {\n');
    s.write('switch(index) {\n');
    for (var i = 0; i < length; i++) {
      s.write('case $i:\n');
      s.write('  return _struct.${elementNamePrefix}$i;\n');
    }
    s.write('default:\n');
    s.write(
        "  throw RangeError('Index \$index must be in the range [0..${length - 1}].');");
    s.write('}\n');
    s.write('}\n');

    // Override toString().
    s.write('@override\n');
    s.write('String toString() {\n');
    s.write("if (length == 0) return '[]';\n");
    s.write("final sb = StringBuffer('[');\n");
    s.write('sb.write(this[0]);\n');
    s.write('for (var i = 1; i < length; i++) {\n');
    s.write("  sb.write(',');\n");
    s.write('  sb.write(this[i]);');
    s.write('}\n');
    s.write("sb.write(']');");
    s.write('return sb.toString();\n');
    s.write('}\n');

    s.write('}\n\n');
    return s.toString();
  }
}
