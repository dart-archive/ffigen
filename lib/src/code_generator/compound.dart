// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

enum CompoundType { struct, union }

/// A binding for Compound type - Struct/Union.
abstract class Compound extends BindingType {
  /// Marker for if a struct definition is complete.
  ///
  /// A function can be safely pass this struct by value if it's complete.
  bool isIncomplete;

  List<Member> members;

  bool get isOpaque => members.isEmpty;

  /// Value for `@Packed(X)` annotation. Can be null (no packing), 1, 2, 4, 8,
  /// or 16.
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
    this.isIncomplete = false,
    this.pack,
    String? dartDoc,
    List<Member>? members,
    bool isInternal = false,
  })  : members = members ?? [],
        super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
          isInternal: isInternal,
        );

  factory Compound.fromType({
    required CompoundType type,
    String? usr,
    String? originalName,
    required String name,
    bool isIncomplete = false,
    int? pack,
    String? dartDoc,
    List<Member>? members,
  }) {
    switch (type) {
      case CompoundType.struct:
        return Struct(
          usr: usr,
          originalName: originalName,
          name: name,
          isIncomplete: isIncomplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
        );
      case CompoundType.union:
        return Union(
          usr: usr,
          originalName: originalName,
          name: name,
          isIncomplete: isIncomplete,
          pack: pack,
          dartDoc: dartDoc,
          members: members,
        );
    }
  }

  List<int> _getArrayDimensionLengths(Type type) {
    final array = <int>[];
    var startType = type;
    while (startType is ConstantArray) {
      array.add(startType.length);
      startType = startType.child;
    }
    return array;
  }

  String _getInlineArrayTypeString(Type type, Writer w) {
    if (type is ConstantArray) {
      return '${w.ffiLibraryPrefix}.Array<'
          '${_getInlineArrayTypeString(type.child, w)}>';
    }
    return type.getCType(w);
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

    /// Marking type names because dart doesn't allow class member to have the
    /// same name as a type name used internally.
    for (final m in members) {
      localUniqueNamer.markUsed(m.type.getFfiDartType(w));
    }

    /// Write @Packed(X) annotation if struct is packed.
    if (isStruct && pack != null) {
      s.write('@${w.ffiLibraryPrefix}.Packed($pack)\n');
    }
    final dartClassName = isStruct ? 'Struct' : 'Union';
    // Write class declaration.
    s.write('final class $enclosingClassName extends ');
    s.write('${w.ffiLibraryPrefix}.${isOpaque ? 'Opaque' : dartClassName}{\n');
    const depth = '  ';
    for (final m in members) {
      m.name = localUniqueNamer.makeUnique(m.name);
      if (m.dartDoc != null) {
        s.write('$depth/// ');
        s.writeAll(m.dartDoc!.split('\n'), '\n$depth/// ');
        s.write('\n');
      }
      if (m.type is ConstantArray) {
        s.write('$depth@${w.ffiLibraryPrefix}.Array.multi(');
        s.write('${_getArrayDimensionLengths(m.type)})\n');
        s.write('${depth}external ${_getInlineArrayTypeString(m.type, w)} ');
        s.write('${m.name};\n\n');
      } else {
        if (!m.type.sameFfiDartAndCType) {
          s.write('$depth@${m.type.getCType(w)}()\n');
        }
        s.write('${depth}external ${m.type.getFfiDartType(w)} ${m.name};\n\n');
      }
    }
    s.write('}\n\n');

    return BindingString(
        type: isStruct ? BindingStringType.struct : BindingStringType.union,
        string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    for (final m in members) {
      m.type.addDependencies(dependencies);
    }
  }

  @override
  bool get isIncompleteCompound => isIncomplete;

  @override
  String getCType(Writer w) => name;

  @override
  bool get sameFfiDartAndCType => true;
}

class Member {
  final String? dartDoc;
  final String originalName;
  String name;
  final Type type;

  Member({
    String? originalName,
    required this.name,
    required this.type,
    this.dartDoc,
  }) : originalName = originalName ?? name;
}
