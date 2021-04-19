// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/typedef.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'utils.dart';
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
class Struc extends NoLookUpBinding {
  /// Marker for if a struct definition is complete.
  ///
  /// A function can be safely pass this struct by value if it's complete.
  bool isInComplete;

  List<Member> members;

  bool get isOpaque => members.isEmpty;

  /// Value for `@Packed(X)` annotation. Can be null(no packing), 1, 2, 4, 8, 16.
  int? pack;

  /// Marker for checking if the dependencies are parsed.
  bool parsedDependencies = false;

  Struc({
    String? usr,
    String? originalName,
    required String name,
    this.isInComplete = false,
    this.pack,
    String? dartDoc,
    List<Member>? members,
  })  : members = members ?? [],
        super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

  List<int> _getArrayDimensionLengths(Type type) {
    final array = <int>[];
    var startType = type;
    while (startType.broadType == BroadType.ConstantArray) {
      array.add(startType.length!);
      startType = startType.child!;
    }
    return array;
  }

  String _getInlineArrayTypeString(Type type, Writer w) {
    if (type.broadType == BroadType.ConstantArray) {
      return '${w.ffiLibraryPrefix}.Array<${_getInlineArrayTypeString(type.child!, w)}>';
    }
    return type.getCType(w);
  }

  List<Typedef>? _typedefDependencies;
  @override
  List<Typedef> getTypedefDependencies(Writer w) {
    if (_typedefDependencies == null) {
      _typedefDependencies = <Typedef>[];

      // Write typedef's required by members and resolve name conflicts.
      for (final m in members) {
        final base = m.type.getBaseType();
        if (base.broadType == BroadType.NativeFunction) {
          _typedefDependencies!.addAll(base.nativeFunc!.getDependencies());
        }
      }
    }
    return _typedefDependencies ?? [];
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingClassName = name;
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }

    /// Adding [enclosingClassName] because dart doesn't allow class member
    /// to have the same name as the class.
    final localUniqueNamer = UniqueNamer({enclosingClassName});

    /// Write @Packed(X) annotation if struct is packed.
    if (pack != null) {
      s.write('@${w.ffiLibraryPrefix}.Packed($pack)\n');
    }
    // Write class declaration.
    s.write(
        'class $enclosingClassName extends ${w.ffiLibraryPrefix}.${isOpaque ? 'Opaque' : 'Struct'}{\n');
    const depth = '  ';
    for (final m in members) {
      final memberName = localUniqueNamer.makeUnique(m.name);
      if (m.type.broadType == BroadType.ConstantArray) {
        s.write(
            '$depth@${w.ffiLibraryPrefix}.Array.multi(${_getArrayDimensionLengths(m.type)})\n');
        s.write(
            '${depth}external ${_getInlineArrayTypeString(m.type, w)} $memberName;\n\n');
      } else {
        if (m.dartDoc != null) {
          s.write(depth + '/// ');
          s.writeAll(m.dartDoc!.split('\n'), '\n' + depth + '/// ');
          s.write('\n');
        }
        if (m.type.isPrimitive) {
          s.write('$depth@${m.type.getCType(w)}()\n');
        }
        s.write('${depth}external ${m.type.getDartType(w)} $memberName;\n\n');
      }
    }
    s.write('}\n\n');

    return BindingString(type: BindingStringType.struc, string: s.toString());
  }
}

class Member {
  final String? dartDoc;
  final String originalName;
  final String name;
  final Type type;

  const Member({
    String? originalName,
    required this.name,
    required this.type,
    this.dartDoc,
  }) : originalName = originalName ?? name;
}
