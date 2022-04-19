// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

/// Type class for return types, variable types, etc.
///
/// Implementers should extend either Type, or BindingType if the type is also a
/// binding, and override at least getCType and toString.
abstract class Type {
  const Type();

  /// Get all dependencies of this type and save them in [dependencies].
  void addDependencies(Set<Binding> dependencies) {}

  /// Get base type for any type.
  ///
  /// E.g int** has base [Type] of int.
  /// double[2][3] has base [Type] of double.
  Type get baseType => this;

  /// Get base Array type.
  ///
  /// Returns itself if it's not an Array Type.
  Type get baseArrayType => this;

  /// Get base typealias type.
  ///
  /// Returns itself if it's not a Typealias.
  Type get typealiasType => this;

  /// Returns true if the type is a [Compound] and is incomplete.
  bool get isIncompleteCompound => false;

  /// Returns the C type of the Type. This is the FFI compatible type that is
  /// passed to native code.
  String getCType(Writer w) => throw 'No mapping for type: $this';

  /// Returns the Dart type of the Type. This is the user visible type that is
  /// passed to Dart code.
  String getDartType(Writer w) => getCType(w);

  /// Returns the string representation of the Type, for debugging purposes
  /// only. This string should not be printed as generated code.
  @override
  String toString();

  /// Cache key used in various places to dedupe Types. By default this is just
  /// the hash of the Type, but in many cases this does not dedupe sufficiently.
  /// So Types that may be duplicated should override this to return a more
  /// specific key. Types that are already deduped don't need to override this.
  /// toString() is not a valid cache key as there may be name collisions.
  String cacheKey() => hashCode.toRadixString(36);
}

/// Function to check if the dart and C type string are same.
bool sameDartAndCType(Type t, Writer w) => t.getCType(w) == t.getDartType(w);

/// Base class for all Type bindings.
///
/// Since Dart doesn't have multiple inheritance, this type exists so that we
/// don't have to reimplement the default methods in all the classes that want
/// to extend both NoLookUpBinding and Type.
abstract class BindingType extends NoLookUpBinding implements Type {
  BindingType({
    String? usr,
    String? originalName,
    required String name,
    String? dartDoc,
  }) : super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        );

  @override
  Type get baseType => this;

  @override
  Type get baseArrayType => this;

  @override
  Type get typealiasType => this;

  @override
  bool get isIncompleteCompound => false;

  @override
  String getDartType(Writer w) => getCType(w);

  @override
  String toString() => originalName;

  @override
  String cacheKey() => hashCode.toRadixString(36);
}

/// Represents an unimplemented type. Used as a marker, so that declarations
/// having these can exclude them.
class UnimplementedType extends Type {
  String reason;
  UnimplementedType(this.reason);

  @override
  String toString() => '(Unimplemented: $reason)';
}
