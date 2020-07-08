// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/typedef.dart';
import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
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
  final String lookupSymbolName;
  final Type type;

  Global({
    @required String name,
    @required this.lookupSymbolName,
    @required this.type,
    String dartDoc,
  }) : super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final globalVarName = name;
    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    final holderVarName = w.wrapperLevelUniqueNamer.makeUnique('_$globalVarName');
    s.write('${w.ffiLibraryPrefix}.Pointer<${type.getCType(w)}> $holderVarName;\n');
    s.write(
        "${type.getDartType(w)} get $globalVarName => ($holderVarName ??= ${w.dylibIdentifier}.lookup<${type.getCType(w)}>('$lookupSymbolName')).value;\n\n");

    return BindingString(type: BindingStringType.global, string: s.toString());
  }

  @override
  List<Typedef> getTypedefDependencies(Writer w) => const [];
}
