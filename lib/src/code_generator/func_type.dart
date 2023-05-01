// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/utils.dart';

import 'writer.dart';

/// Represents a function type.
class FunctionType extends Type {
  final Type returnType;
  final List<Parameter> parameters;
  final List<Parameter> varArgParameters;

  /// Get all the parameters for generating the dart type. This includes both
  /// [parameters] and [varArgParameters].
  List<Parameter> get dartTypeParameters => parameters + varArgParameters;

  FunctionType({
    required this.returnType,
    required this.parameters,
    this.varArgParameters = const [],
  });

  String _getCacheKeyString(
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
  String getCType(Writer w, {bool writeArgumentNames = true}) {
    final sb = StringBuffer();

    // Write return Type.
    sb.write(returnType.getCType(w));

    // Write Function.
    sb.write(' Function(');
    sb.write((parameters).map<String>((p) {
      return '${p.type.getCType(w)} ${writeArgumentNames ? p.name : ""}';
    }).join(', '));
    if (varArgParameters.isNotEmpty) {
      sb.write(", ${w.ffiLibraryPrefix}.VarArgs<(");
      sb.write((varArgParameters).map<String>((p) {
        return '${p.type.getCType(w)} ${writeArgumentNames ? p.name : ""}';
      }).join(', '));
      sb.write(",)>");
    }
    sb.write(')');

    return sb.toString();
  }

  @override
  String getDartType(Writer w, {bool writeArgumentNames = true}) {
    final sb = StringBuffer();

    // Write return Type.
    sb.write(returnType.getDartType(w));

    // Write Function.
    sb.write(' Function(');
    sb.write(dartTypeParameters.map<String>((p) {
      return '${p.type.getDartType(w)} ${writeArgumentNames ? p.name : ""}';
    }).join(', '));
    sb.write(')');

    return sb.toString();
  }

  @override
  String toString() => _getCacheKeyString(false, (Type t) => t.toString());

  @override
  String cacheKey() => _getCacheKeyString(false, (Type t) => t.cacheKey());

  @override
  void addDependencies(Set<Binding> dependencies) {
    returnType.addDependencies(dependencies);
    for (final p in parameters) {
      p.type.addDependencies(dependencies);
    }
  }

  void addParameterNames(List<String> names) {
    if (names.length != parameters.length) {
      return;
    }
    final paramNamer = UniqueNamer({});
    for (int i = 0; i < parameters.length; i++) {
      final finalName = paramNamer.makeUnique(names[i]);
      parameters[i] = Parameter(
        type: parameters[i].type,
        originalName: names[i],
        name: finalName,
      );
    }
  }
}

/// Represents a NativeFunction<Function>.
class NativeFunc extends Type {
  final FunctionType type;

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
