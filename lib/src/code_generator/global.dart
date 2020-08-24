// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

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
    String usr,
    String originalName,
    @required String name,
    @required this.type,
    String dartDoc,
  }) : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final globalVarName = name;
    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc));
    }

    final holderVarName =
        w.wrapperLevelUniqueNamer.makeUnique('_$globalVarName');
    s.write(
        '${w.ffiLibraryPrefix}.Pointer<${type.getCType(w)}> $holderVarName;\n');
    s.write(
        "${type.getDartType(w)} get $globalVarName => ($holderVarName ??= ${w.dylibIdentifier}.lookup<${type.getCType(w)}>('$originalName')).value;\n\n");

    return BindingString(type: BindingStringType.global, string: s.toString());
  }
}
