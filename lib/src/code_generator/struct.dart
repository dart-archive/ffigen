// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/compound.dart';

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
class Struct extends Compound {
  Struct({
    String? usr,
    String? originalName,
    required String name,
    bool isIncomplete = false,
    int? pack,
    String? dartDoc,
    List<Member>? members,
    bool isInternal = false,
  }) : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
          isIncomplete: isIncomplete,
          members: members,
          pack: pack,
          compoundType: CompoundType.struct,
          isInternal: isInternal,
        );
}
