// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/compound.dart';

/// A binding for a C union -
///
/// ```c
/// union C {
///   int a;
///   double b;
///   float c;
/// };
/// ```
/// The generated dart code is -
/// ```dart
/// class Union extends ffi.Union{
///  @ffi.Int32()
///  int a;
///
///  @ffi.Double()
///  double b;
///
///  @ffi.Float()
///  float c;
///
/// }
/// ```
class Union extends Compound {
  Union({
    String? usr,
    String? originalName,
    required String name,
    bool isIncomplete = false,
    int? pack,
    String? dartDoc,
    List<Member>? members,
  }) : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
          isIncomplete: isIncomplete,
          members: members,
          pack: pack,
          compoundType: CompoundType.union,
        );
}
