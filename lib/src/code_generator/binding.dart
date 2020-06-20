// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'binding_string.dart';
import 'writer.dart';

/// Base class for all Bindings.
abstract class Binding {
  final String name;

  final String dartDoc;

  const Binding({@required this.name, this.dartDoc});

  /// Converts a Binding to its actual string representation.
  BindingString toBindingString(Writer w);
}
