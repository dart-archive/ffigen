// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A Binding's String representation.
class BindingString {
  // Meta data, (not used for generation).
  final BindingStringType type;
  final String string;

  const BindingString({required this.type, required this.string});

  @override
  String toString() => string;
}

/// A [BindingString]'s type.
enum BindingStringType {
  func,
  struc,
  union,
  constant,
  global,
  enumClass,
  typeDef,
}
