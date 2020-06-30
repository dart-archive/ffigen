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

  List<int> _getArrayDimensionLengths(Type type) {
    final array = <int>[];
    var startType = type;
    while (startType.broadType == BroadType.ConstantArray) {
      array.add(startType.length);
      startType = startType.child;
    }
    return array;
  }

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
          helperClassName: 'ArrayHelper_${name}_${m.name}',
          elementType: m.type.getBaseArrayType(),
          dimensions: _getArrayDimensionLengths(m.type),
          name: m.name,
          structName: name,
          elementNamePrefix: '_${m.name}_item_',
        );
        s.write(arrayHelper.declarationString(w));
        helpers.add(arrayHelper);
      } else {
        const depth = '  ';
        if (m.dartDoc != null) {
          s.write(depth + '/// ');
          s.writeAll(m.dartDoc.split('\n'), '\n' + depth + '/// ');
          s.write('\n');
        }
        if (m.type.isPrimitive) {
          s.write('$depth@${m.type.getCType(w)}()\n');
        }
        s.write('$depth${m.type.getDartType(w)} ${m.name};\n\n');
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
  final String dartDoc;
  final String name;
  final Type type;

  const Member({this.name, this.type, this.dartDoc});
}

// Helper bindings for struct array.
class ArrayHelper {
  final Type elementType;
  final List<int> dimensions;
  final String structName;

  final String name;
  final String helperClassName;
  final String elementNamePrefix;

  int _expandedArrayLength;
  int get expandedArrayLength {
    if (_expandedArrayLength != null) return _expandedArrayLength;

    int arrayLength = 1;
    for (final i in dimensions) {
      arrayLength = arrayLength * i;
    }
    return arrayLength;
  }

  ArrayHelper({
    @required this.elementType,
    @required this.dimensions,
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

    for (int i = 0; i < expandedArrayLength; i++) {
      if (elementType.isPrimitive) {
        s.write('  @${arrayCType}()\n');
      }
      s.write('  ${arrayDartType} ${elementNamePrefix}$i;\n');
    }

    s.write('/// Helper for array `$name`.\n');
    s.write(
        '$helperClassName get $name => ${helperClassName}(this, $dimensions);\n');

    return s.toString();
  }

  /// Creates an array helper binding for struct array.
  String helperClassString(Writer w) {
    final s = StringBuffer();

    final arrayType = elementType.getDartType(w);

    s.write('/// Helper for array `$name` in struct `$structName`.\n');

    // Write class declaration.
    s.write('class $helperClassName{\n');
    s.write('final $structName _struct;\n');
    s.write('final List<int> dimensions;\n');
    s.write('$helperClassName(this._struct, this.dimensions);\n');

    final indexSwitchKey = _getIndexSwitchKey();
    // Add _checkArrayBounds method
    s.write('void _checkArrayBounds(${_getIndexParameters()}) {\n');
    for (int i = 0; i < dimensions.length; i++) {
      s.write('if(i${i + 1}<0 || i${i + 1}>=dimensions[$i]){\n');
      s.write(
          "throw RangeError('i${i + 1} not in range 0..${dimensions[i]} exclusive.');");
      s.write('}');
    }
    s.write('}\n');

    // Add setValue method.
    s.write('void setValue(${_getIndexParameters()}$arrayType value) {\n');
    s.write('_checkArrayBounds(${_getIndexParameters(false)});\n');
    s.write('switch(${indexSwitchKey}) {\n');
    for (int i = 0; i < expandedArrayLength; i++) {
      s.write('case $i:\n');
      s.write('  _struct.${elementNamePrefix}$i = value;\n');
      s.write('  break;\n');
    }
    s.write('default:\n');
    s.write("  throw RangeError('Index(s) not in range');");
    s.write('}\n');
    s.write('}\n');

    // Add getValue method.
    s.write('$arrayType getValue(${_getIndexParameters()}) {\n');
    s.write('_checkArrayBounds(${_getIndexParameters(false)});\n');
    s.write('switch(${indexSwitchKey}) {\n');
    for (int i = 0; i < expandedArrayLength; i++) {
      s.write('case $i:\n');
      s.write('  return _struct.${elementNamePrefix}$i;\n');
    }
    s.write('default:\n');
    s.write("  throw RangeError('Index(s) not in range');");
    s.write('}\n');
    s.write('}\n');

    s.write('}\n\n');
    return s.toString();
  }

  /// Returns raw index parameters as string.
  ///
  /// E.g -> If [dimensions.dimensions] = 3,
  /// output: "int i1, int i2, int i3,"
  ///
  /// If [addType] is false types are removed.
  ///
  /// E.g -> If [dimensions.dimensions] = 3,
  /// output: "i1,i2,i3,"
  String _getIndexParameters([bool addType = true]) {
    final sb = StringBuffer();
    for (var i = 0; i < dimensions.length; i++) {
      if (addType) {
        sb.write('int i${i + 1}, ');
      } else {
        sb.write('i${i + 1}, ');
      }
    }
    return sb.toString();
  }

  /// Maps n-D array to 1-D array.
  String _getIndexSwitchKey() {
    final sb = StringBuffer();
    for (int i = 0; i < dimensions.length - 1; i++) {
      sb.write('i${i + 1}');
      for (int j = i + 1; j < dimensions.length; j++) {
        sb.write('*dimensions[${j}]');
      }
      sb.write('+');
    }
    sb.write('i${dimensions.length}');
    return sb.toString();
  }
}
