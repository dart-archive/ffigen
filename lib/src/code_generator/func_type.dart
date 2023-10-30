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

  String _getTypeImpl(
      bool writeArgumentNames, String Function(Type) typeToString,
      {String? varArgWrapper}) {
    final params = varArgWrapper != null ? parameters : dartTypeParameters;
    String? varArgPack;
    if (varArgWrapper != null && varArgParameters.isNotEmpty) {
      final varArgPackBuf = StringBuffer();
      varArgPackBuf.write("$varArgWrapper<(");
      varArgPackBuf.write((varArgParameters).map<String>((p) {
        return '${typeToString(p.type)} ${writeArgumentNames ? p.name : ""}';
      }).join(', '));
      varArgPackBuf.write(",)>");
      varArgPack = varArgPackBuf.toString();
    }

    // Write return Type.
    final sb = StringBuffer();
    sb.write(typeToString(returnType));

    // Write Function.
    sb.write(' Function(');
    sb.write([
      ...params.map<String>((p) {
        return '${typeToString(p.type)} ${writeArgumentNames ? p.name : ""}';
      }),
      if (varArgPack != null) varArgPack,
    ].join(', '));
    sb.write(')');

    return sb.toString();
  }

  @override
  String getCType(Writer w, {bool writeArgumentNames = true}) =>
      _getTypeImpl(writeArgumentNames, (Type t) => t.getCType(w),
          varArgWrapper: '${w.ffiLibraryPrefix}.VarArgs');

  @override
  String getFfiDartType(Writer w, {bool writeArgumentNames = true}) =>
      _getTypeImpl(writeArgumentNames, (Type t) => t.getFfiDartType(w));

  @override
  String getDartType(Writer w, {bool writeArgumentNames = true}) =>
      _getTypeImpl(writeArgumentNames, (Type t) => t.getDartType(w));

  @override
  bool get sameFfiDartAndCType =>
      returnType.sameFfiDartAndCType &&
      dartTypeParameters.every((p) => p.type.sameFfiDartAndCType);

  @override
  bool get sameDartAndCType =>
      returnType.sameDartAndCType &&
      dartTypeParameters.every((p) => p.type.sameDartAndCType);

  @override
  bool get sameDartAndFfiDartType =>
      returnType.sameDartAndFfiDartType &&
      dartTypeParameters.every((p) => p.type.sameDartAndFfiDartType);

  @override
  String toString() => _getTypeImpl(false, (Type t) => t.toString());

  @override
  String cacheKey() => _getTypeImpl(false, (Type t) => t.cacheKey());

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
  // Either a FunctionType or a Typealias of a FunctionType.
  final Type _type;

  NativeFunc(this._type) {
    assert(_type is FunctionType || _type is Typealias);
  }

  FunctionType get type {
    if (_type is Typealias) {
      return _type.typealiasType as FunctionType;
    }
    return _type as FunctionType;
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    _type.addDependencies(dependencies);
  }

  @override
  String getCType(Writer w) =>
      '${w.ffiLibraryPrefix}.NativeFunction<${_type.getCType(w)}>';

  @override
  String getFfiDartType(Writer w) => getCType(w);

  @override
  bool get sameFfiDartAndCType => true;

  @override
  String toString() => 'NativeFunction<${_type.toString()}>';

  @override
  String cacheKey() => 'NatFn(${_type.cacheKey()})';
}
