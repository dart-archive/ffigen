// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:wasmjsgen/src/code_generator.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding for C function.
///
/// For a C function -
/// ```c
/// int sum(int a, int b);
/// ```
/// The Generated dart code is -
/// ```dart
/// int sum(int a, int b) {
///   return _sum(a, b);
/// }
///
/// final _dart_sum _sum = _dylib.lookupFunction<_c_sum, _dart_sum>('sum');
///
/// typedef _c_sum = ffi.Int32 Function(ffi.Int32 a, ffi.Int32 b);
///
/// typedef _dart_sum = int Function(int a, int b);
/// ```
class Func extends LookUpBinding {
  final FunctionType functionType;
  final bool exposeSymbolAddress;
  final bool exposeFunctionTypedefs;

  /// Contains typealias for function type if [exposeFunctionTypedefs] is true.
  Typealias? _exposedCFunctionTypealias, _exposedDartFunctionTypealias;

  /// [originalName] is looked up in dynamic library, if not
  /// provided, takes the value of [name].
  Func({
    String? usr,
    required String name,
    String? originalName,
    String? dartDoc,
    required Type returnType,
    List<Parameter>? parameters,
    this.exposeSymbolAddress = false,
    this.exposeFunctionTypedefs = false,
  })  : functionType = FunctionType(
          returnType: returnType,
          parameters: parameters ?? const [],
        ),
        super(
          usr: usr,
          originalName: originalName,
          name: name,
          dartDoc: dartDoc,
        ) {
    for (var i = 0; i < functionType.parameters.length; i++) {
      if (functionType.parameters[i].name.trim() == '') {
        functionType.parameters[i].name = 'arg$i';
      }
    }

    // Get function name with first letter in upper case.
    final upperCaseName = name[0].toUpperCase() + name.substring(1);
    if (exposeFunctionTypedefs) {
      _exposedCFunctionTypealias = Typealias(
        name: 'Native$upperCaseName',
        type: Type.functionType(functionType),
      );
      _exposedDartFunctionTypealias = Typealias(
        name: 'Dart$upperCaseName',
        type: Type.functionType(functionType),
        useDartType: true,
      );
    }
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingFuncName = name;
    final funcVarName = w.wrapperLevelUniqueNamer.makeUnique('_$name');

    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    // Resolve name conflicts in function parameter names.
    final paramNamer = UniqueNamer({});
    for (final p in functionType.parameters) {
      p.name = paramNamer.makeUnique(p.name);
    }

    // -----------------
    // Enclosing Function
    // -----------------

    final returnType = (w.dartBool &&
            functionType.returnType.getBaseTypealiasType().broadType ==
                BroadType.Boolean)
        ? 'bool'
        : functionType.returnType.getDartType(w);
    s.write('$returnType $enclosingFuncName(\n');

    // Input params
    for (final p in functionType.parameters) {
      if (w.dartBool &&
          p.type.getBaseTypealiasType().broadType == BroadType.Boolean) {
        // Use bool parameter type in enclosing function.
        s.write('  bool ${p.name},\n');
      } else {
        s.write('  ${p.type.getDartType(w)} ${p.name},\n');
      }
    }

    // Function body
    final returnOpen = functionType.returnType.getReturnWrapOpen(w);
    final returnClose = functionType.returnType.getReturnWrapClose(w);
    s.write(') {\n');

    s.write('return $returnOpen$funcVarName');

    s.write('(\n');
    for (final p in functionType.parameters) {
      final resolution = p.type.getParameterResolution(w);
      s.write('    ${p.name}$resolution,\n');
    }
    s.write('$returnClose);\n');
    s.write('}\n');

    // -----------------
    // Enclosed Function
    // -----------------
    s.write(
        'late final ${functionType.returnType.getLookupDartType(w)} Function(');
    for (final p in functionType.parameters) {
      s.write('${p.type.getLookupDartType(w)},\n');
    }
    s.write(
        ") $funcVarName =${w.lookupFuncIdentifier}('$enclosingFuncName');\n");

    return BindingString(type: BindingStringType.func, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    functionType.addDependencies(dependencies);
    if (exposeFunctionTypedefs) {
      _exposedCFunctionTypealias!.addDependencies(dependencies);
      _exposedDartFunctionTypealias!.addDependencies(dependencies);
    }
  }
}

/// Represents a Parameter, used in [Func] and [Typealias].
class Parameter {
  final String? originalName;
  String name;
  final Type type;

  Parameter({String? originalName, this.name = '', required Type type})
      : originalName = originalName ?? name,
        // A type with broadtype [BroadType.NativeFunction] is wrapped with a
        // pointer because this is a shorthand used in C for Pointer to function.
        type = type.getBaseTypealiasType().broadType == BroadType.NativeFunction
            ? Type.pointer(type)
            : type;
}
