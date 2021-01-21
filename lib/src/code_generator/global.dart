// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/typedef.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding to a global variable
///
/// For a C global variable -
/// ```c
/// int a;
/// ```
/// The generated dart code is -
/// ```dart
/// final int a = _dylib.lookup<ffi.Int32>('a').value;
/// ```
class Global extends LookUpBinding {
  final Type type;

  Global({
    String? usr,
    String? originalName,
    required String name,
    required this.type,
    String? dartDoc,
  }) : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

  List<Typedef>? _typedefDependencies;
  @override
  List<Typedef> getTypedefDependencies(Writer w) {
    if (_typedefDependencies == null) {
      _typedefDependencies = <Typedef>[];

      // Add typedef's required by the variable's type.
      final valueType = type.getBaseType();
      if (valueType.broadType == BroadType.NativeFunction) {
        _typedefDependencies!.addAll(valueType.nativeFunc!.getDependencies());
      }
    }
    return _typedefDependencies!;
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final globalVarName = name;
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    final pointerName = w.wrapperLevelUniqueNamer.makeUnique('_$globalVarName');
    final dartType = type.getDartType(w);
    final cType = type.getCType(w);

    s.write(
        "late final ${w.ffiLibraryPrefix}.Pointer<$cType> $pointerName = ${w.dylibIdentifier}.lookup<$cType>('$originalName');\n\n");
    if (type.broadType == BroadType.Struct) {
      if (type.struc!.isOpaque) {
        s.write(
            '${w.ffiLibraryPrefix}.Pointer<$cType> get $globalVarName => $pointerName;\n\n');
      } else {
        s.write('$dartType get $globalVarName => $pointerName.ref;\n\n');
      }
    } else {
      s.write('$dartType get $globalVarName => $pointerName.value;\n\n');
      s.write(
          'set $globalVarName($dartType value) => $pointerName.value = value;\n\n');
    }

    return BindingString(type: BindingStringType.global, string: s.toString());
  }
}
