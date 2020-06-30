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
          length: _getArrayDimensionLengths(m.type),
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
  final List<int> length;
  final String structName;

  final String name;
  final String helperClassName;
  final String elementNamePrefix;

  List<String> _expandedElements;
  List<String> get expandedElements {
    _expandedElements ??= length.isEmpty ? [] : _expandElements(length, 0);
    return _expandedElements;
  }

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

    for (final arrayString in expandedElements) {
      if (elementType.isPrimitive) {
        s.write('  @${arrayCType}()\n');
      }
      s.write('  ${arrayDartType} ${elementNamePrefix}$arrayString;\n');
    }

    s.write('/// Helper for array `$name`\n');
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
    s.write('final List<int> length;\n');
    s.write('$helperClassName(this._struct, this.length);\n');

    // add setValue method.
    s.write('void setValue(${_getIndexParameters()}$arrayType value) {\n');
    s.write('switch(\'${_getIndexSwitchKey()}\') {\n');
    for (final arrayElement in expandedElements) {
      s.write('case \'$arrayElement\':\n');
      s.write('  _struct.${elementNamePrefix}$arrayElement = value;\n');
      s.write('  break;\n');
    }
    s.write('default:\n');
    s.write("  throw RangeError('Index(s) not in range');");
    s.write('}\n');
    s.write('}\n');

    // add getValue method.
    s.write('$arrayType getValue(${_getIndexParameters()}) {\n');
    s.write('switch(\'${_getIndexSwitchKey()}\') {\n');
    for (final arrayElement in expandedElements) {
      s.write('case \'$arrayElement\':\n');
      s.write('  return _struct.${elementNamePrefix}$arrayElement;\n');
    }
    s.write('default:\n');
    s.write("  throw RangeError('Index(s) not in range');");
    s.write('}\n');
    s.write('}\n');

    s.write('}\n\n');
    return s.toString();
  }

  /// Expands a List to cover all permutations sequentially
  ///
  /// E.g -> input: [2,2], output: ['0_0','0_1','1_0','1_1']
  ///
  /// Ensure that list isn't empty
  List<String> _expandElements(List<int> list, int startIndex) {
    final returnString = <String>[];
    for (var i = 0; i < list[startIndex]; i++) {
      if (startIndex == list.length - 1) {
        // base case for recursion.
        returnString.add('$i');
      } else {
        for (final s in _expandElements(list, startIndex + 1)) {
          returnString.add('${i}_${s}');
        }
      }
    }
    return returnString;
  }

  /// Returns index parameters to use direct
  ///
  /// E.g -> If [length.length] = 3,
  /// output: "int i1, int i2, int i3,"
  String _getIndexParameters() {
    final sb = StringBuffer();
    for (var i = 0; i < length.length; i++) {
      sb.write('int i${i + 1}, ');
    }
    return sb.toString();
  }

  /// Returns index switch key
  ///
  /// E.g -> If [length.length] = 3,
  /// output: "${i1}_${i2}_${i3}"
  String _getIndexSwitchKey() {
    final sb = StringBuffer();
    sb.write(r'${i1}');
    for (var i = 1; i < length.length; i++) {
      sb.write(r'_${i2}');
    }
    return sb.toString();
  }
}
