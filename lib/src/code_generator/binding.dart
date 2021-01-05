// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'binding_string.dart';
import 'typedef.dart';
import 'writer.dart';

/// Base class for all Bindings.
///
/// Do not extend directly, use [LookUpBinding] or [NoLookUpBinding].
abstract class Binding {
  /// Holds the Unified Symbol Resolution string obtained from libclang.
  final String usr;

  /// The name as it was in C.
  final String originalName;

  /// Binding name to generate, may get changed to resolve name conflicts.
  String name;

  final String? dartDoc;

  Binding({
    required this.usr,
    required this.originalName,
    required this.name,
    this.dartDoc,
  });

  /// Return typedef dependencies.
  List<Typedef> getTypedefDependencies(Writer w) => const [];

  /// Converts a Binding to its actual string representation.
  ///
  /// Note: This does not print the typedef dependencies.
  /// Must call [getTypedefDependencies] first.
  BindingString toBindingString(Writer w);
}

/// Base class for bindings which look up symbols in dynamic library.
abstract class LookUpBinding extends Binding {
  LookUpBinding({
    String? usr,
    String? originalName,
    required String name,
    String? dartDoc,
  }) : super(
          usr: usr ?? name,
          originalName: originalName ?? name,
          name: name,
          dartDoc: dartDoc,
        );
}

/// Base class for bindings which don't look up symbols in dynamic library.
abstract class NoLookUpBinding extends Binding {
  NoLookUpBinding({
    String? usr,
    String? originalName,
    required String name,
    String? dartDoc,
  }) : super(
          usr: usr ?? name,
          originalName: originalName ?? name,
          name: name,
          dartDoc: dartDoc,
        );
}
