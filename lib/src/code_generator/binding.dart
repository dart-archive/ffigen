// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'binding_string.dart';
import 'writer.dart';

/// A binding class, parent class of all possible types
abstract class Binding {
  /// Name of element
  final String name;

  /// DartDoc for this (Optional)
  final String dartDoc;

  const Binding({@required this.name, this.dartDoc});

  /// Converts an abstract Binding to its string representation
  BindingString toBindingString(Writer w);
}
