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
          helperClassGroupName: 'ArrayHelper_${name}_${m.name}',
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
  final String helperClassGroupName;
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
    @required this.helperClassGroupName,
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
        '${helperClassGroupName}_level0 get $name => ${helperClassGroupName}_level0(this, $dimensions, 0, 0);\n');

    return s.toString();
  }

  String helperClassString(Writer w) {
    final s = StringBuffer();
    final arrayType = elementType.getDartType(w);
    for (int dim = 0; dim < dimensions.length; dim++) {
      final helperClassName = '${helperClassGroupName}_level${dim}';
      final structIdentifier = '_struct';
      final dimensionsIdentifier = 'dimensions';
      final levelIdentifier = 'level';
      final absoluteIndexIdentifier = '_absoluteIndex';
      final checkBoundsFunctionIdentifier = '_checkBounds';
      final legthIdentifier = 'length';

      s.write('/// Helper for array `$name` in struct `$structName`.\n');

      // Write class declaration.
      s.write('class ${helperClassName}{\n');
      s.write('final $structName $structIdentifier;\n');
      s.write('final List<int> $dimensionsIdentifier;\n');
      s.write('final int $levelIdentifier;\n');
      s.write('final int $absoluteIndexIdentifier;\n');
      s.write(
          'int get $legthIdentifier => $dimensionsIdentifier[$levelIdentifier];\n');

      // Write class constructor.
      s.write(
          '$helperClassName(this.$structIdentifier, this.$dimensionsIdentifier, this.$levelIdentifier, this.$absoluteIndexIdentifier);\n');

      // Write checkBoundsFunction.
      s.write('''
  void $checkBoundsFunctionIdentifier(int index) {
    if (index >= $legthIdentifier || index < 0) {
      throw RangeError('Dimension \$$levelIdentifier: index not in range 0..\${$legthIdentifier} exclusive.');
    }
  }
  ''');
      // If this isn't the last level.
      if (dim + 1 != dimensions.length) {
        // Override [] operator.
        s.write('''
  ${helperClassGroupName}_level${dim + 1} operator [](int index) {
    $checkBoundsFunctionIdentifier(index);
    int offset = index;
    for (int i = level + 1; i < $dimensionsIdentifier.length; i++) {
      offset *= $dimensionsIdentifier[i];
    }
    return ${helperClassGroupName}_level${dim + 1}(
        $structIdentifier, $dimensionsIdentifier, $levelIdentifier + 1, $absoluteIndexIdentifier + offset);
  }
''');
      } else {
        // This is the last level, add switching logic here.
        // Override [] operator.
        s.write('$arrayType operator[](int index){\n');
        s.write('$checkBoundsFunctionIdentifier(index);\n');
        s.write('switch($absoluteIndexIdentifier+index){\n');
        for (int i = 0; i < expandedArrayLength; i++) {
          s.write('case $i:\n');
          s.write('  return $structIdentifier.${elementNamePrefix}$i;\n');
        }
        s.write('default:\n');
        s.write("  throw Exception('Invalid Array Helper generated.');");
        s.write('}\n');
        s.write('}\n');

        // Override []= operator.
        s.write('void operator[]=(int index, $arrayType value){\n');
        s.write('$checkBoundsFunctionIdentifier(index);\n');
        s.write('switch($absoluteIndexIdentifier+index){\n');
        for (int i = 0; i < expandedArrayLength; i++) {
          s.write('case $i:\n');
          s.write('  $structIdentifier.${elementNamePrefix}$i = value;\n');
          s.write('  break;\n');
        }
        s.write('default:\n');
        s.write("  throw Exception('Invalid Array Helper generated.');\n");
        s.write('}\n');
        s.write('}\n');
      }
      s.write('}\n');
    }
    return s.toString();
  }
}
