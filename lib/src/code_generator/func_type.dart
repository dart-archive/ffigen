// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'writer.dart';

/// Represents a function type.
class FunctionType extends Type {
  final Type returnType;
  final List<Parameter> parameters;

  FunctionType({
    required this.returnType,
    required this.parameters,
  });

  String _getTypeString(
      bool writeArgumentNames, String Function(Type) typeToString) {
    final sb = StringBuffer();

    // Write return Type.
    sb.write(typeToString(returnType));

    // Write Function.
    sb.write(' Function(');
    sb.write(parameters.map<String>((p) {
      return '${typeToString(p.type)} ${writeArgumentNames ? p.name : ""}';
    }).join(', '));
    sb.write(')');

    return sb.toString();
  }

  @override
  String getCType(Writer w, {bool writeArgumentNames = true}) =>
      _getTypeString(writeArgumentNames, (Type t) => t.getCType(w));

  @override
  String getDartType(Writer w, {bool writeArgumentNames = true}) =>
      _getTypeString(writeArgumentNames, (Type t) => t.getDartType(w));

  @override
  String toString() => _getTypeString(false, (Type t) => t.toString());

  @override
  String cacheKey() => _getTypeString(false, (Type t) => t.cacheKey());

  @override
  void addDependencies(Set<Binding> dependencies) {
    returnType.addDependencies(dependencies);
    for (final p in parameters) {
      p.type.addDependencies(dependencies);
    }
  }
}

/// Represents a NativeFunction<Function>.
class NativeFunc extends Type {
  final Type type;

  NativeFunc(this.type);

  @override
  void addDependencies(Set<Binding> dependencies) {
    type.addDependencies(dependencies);
  }

  @override
  String getCType(Writer w) =>
      '${w.ffiLibraryPrefix}.NativeFunction<${type.getCType(w)}>';

  @override
  String getDartType(Writer w) =>
      '${w.ffiLibraryPrefix}.NativeFunction<${type.getCType(w)}>';

  @override
  String toString() => 'NativeFunction<${type.toString()}>';

  @override
  String cacheKey() => 'NatFn(${type.cacheKey()})';
}
