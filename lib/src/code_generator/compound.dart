// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/typedef.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

enum CompoundType { struct, union }

/// A binding for Compound type - Struct/Union.
abstract class Compound extends NoLookUpBinding {
  /// Marker for if a struct definition is complete.
  ///
  /// A function can be safely pass this struct by value if it's complete.
  bool isInComplete;

  List<Member> members;

  bool get isOpaque => members.isEmpty;

  /// Value for `@Packed(X)` annotation. Can be null(no packing), 1, 2, 4, 8, 16.
  ///
  /// Only supported for [CompoundType.struct].
  int? pack;

  /// Marker for checking if the dependencies are parsed.
  bool parsedDependencies = false;

  CompoundType compoundType;
  bool get isStruct => compoundType == CompoundType.struct;
  bool get isUnion => compoundType == CompoundType.union;

  Compound({
    String? usr,
    String? originalName,
    required String name,
    required this.compoundType,
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

  factory Compound.fromType({
    required CompoundType type,
    String? usr,
    String? originalName,
    required String name,
    bool isInComplete = false,
    int? pack,
    String? dartDoc,
    List<Member>? members,
  }) {
    switch (type) {
      case CompoundType.struct:
        return Struc(
          usr: usr,
          originalName: originalName,
          name: name,
          isInComplete: isInComplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
        );
      case CompoundType.union:
        return Union(
          usr: usr,
          originalName: originalName,
          name: name,
          isInComplete: isInComplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
        );
    }
  }

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
    if (isStruct && pack != null) {
      s.write('@${w.ffiLibraryPrefix}.Packed($pack)\n');
    }
    final dartClassName = isStruct ? 'Struct' : 'Union';
    // Write class declaration.
    s.write(
        'class $enclosingClassName extends ${w.ffiLibraryPrefix}.${isOpaque ? 'Opaque' : dartClassName}{\n');
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

    return BindingString(
        type: isStruct ? BindingStringType.struc : BindingStringType.union,
        string: s.toString());
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
