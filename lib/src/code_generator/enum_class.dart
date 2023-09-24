// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'binding.dart';
import 'binding_string.dart';
import 'native_type.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding for enums in C.
///
/// For a C enum -
/// ```c
/// enum Fruits {apple, banana = 10};
/// ```
/// The generated dart code is
///
/// ```dart
/// class Fruits {
///   static const apple = 0;
///   static const banana = 10;
/// }
/// ```
class EnumClass extends BindingType {
  static final nativeType = NativeType(SupportedNativeType.Int32);

  final List<EnumConstant> enumConstants;

  EnumClass({
    String? usr,
    String? originalName,
    required String name,
    String? dartDoc,
    List<EnumConstant>? enumConstants,
  })  : enumConstants = enumConstants ?? [],
        super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

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

    // Print enclosing class.
    s.write('abstract class $enclosingClassName {\n');
    const depth = '  ';
    for (final ec in enumConstants) {
      final enumValueName = localUniqueNamer.makeUnique(ec.name);
      if (ec.dartDoc != null) {
        s.write('$depth/// ');
        s.writeAll(ec.dartDoc!.split('\n'), '\n$depth/// ');
        s.write('\n');
      }
      s.write('${depth}static const int $enumValueName = ${ec.value};\n');
    }
    s.write('}\n\n');

    return BindingString(
        type: BindingStringType.enumClass, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
  }

  @override
  String getCType(Writer w) => nativeType.getCType(w);

  @override
  String getFfiDartType(Writer w) => nativeType.getFfiDartType(w);

  @override
  String? getDefaultValue(Writer w, String nativeLib) => '0';
}

/// Represents a single value in an enum.
class EnumConstant {
  final String? originalName;
  final String? dartDoc;
  final String name;
  final int value;
  const EnumConstant({
    String? originalName,
    required this.name,
    required this.value,
    this.dartDoc,
  }) : originalName = originalName ?? name;
}
