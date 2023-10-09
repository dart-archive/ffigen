// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

/// Represents a Dart_Handle.
class HandleType extends Type {
  const HandleType._();
  static const _handle = HandleType._();
  factory HandleType() => _handle;

  @override
  String getCType(Writer w) => '${w.ffiLibraryPrefix}.Handle';

  @override
  String getFfiDartType(Writer w) => 'Object';

  @override
  bool get sameFfiDartAndCType => false;

  @override
  String toString() => 'Handle';
}
