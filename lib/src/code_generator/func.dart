// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config_types.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

/// A binding for C function.
///
/// For example, take the following C function.
///
/// ```c
/// int sum(int a, int b);
/// ```
///
/// The generated Dart code for this function (without `FfiNative`) is as follows.
///
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
///
/// When using `Native`, the code is as follows.
///
/// ```dart
/// @ffi.Native<ffi.Int32 Function(ffi.Int32 a, ffi.Int32 b)>('sum')
/// external int sum(int a, int b);
/// ```
class Func extends LookUpBinding {
  final FunctionType functionType;
  final bool exposeSymbolAddress;
  final bool exposeFunctionTypedefs;
  final bool isLeaf;
  final FfiNativeConfig ffiNativeConfig;
  late final String funcPointerName;

  /// Contains typealias for function type if [exposeFunctionTypedefs] is true.
  Typealias? _exposedFunctionTypealias;

  /// [originalName] is looked up in dynamic library, if not
  /// provided, takes the value of [name].
  Func({
    super.usr,
    required String name,
    super.originalName,
    super.dartDoc,
    required Type returnType,
    List<Parameter>? parameters,
    List<Parameter>? varArgParameters,
    this.exposeSymbolAddress = false,
    this.exposeFunctionTypedefs = false,
    this.isLeaf = false,
    super.isInternal,
    this.ffiNativeConfig = const FfiNativeConfig(enabled: false),
  })  : functionType = FunctionType(
          returnType: returnType,
          parameters: parameters ?? const [],
          varArgParameters: varArgParameters ?? const [],
        ),
        super(
          name: name,
        ) {
    for (var i = 0; i < functionType.parameters.length; i++) {
      if (functionType.parameters[i].name.trim() == '') {
        functionType.parameters[i].name = 'arg$i';
      }
    }

    // Get function name with first letter in upper case.
    final upperCaseName = name[0].toUpperCase() + name.substring(1);
    if (exposeFunctionTypedefs) {
      _exposedFunctionTypealias = Typealias(
        name: upperCaseName,
        type: functionType,
        genFfiDartType: true,
        isInternal: true,
      );
    }
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingFuncName = name;
    final funcVarName = w.wrapperLevelUniqueNamer.makeUnique('_$name');
    funcPointerName = w.wrapperLevelUniqueNamer.makeUnique('_${name}Ptr');

    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    // Resolve name conflicts in function parameter names.
    final paramNamer = UniqueNamer({});
    for (final p in functionType.dartTypeParameters) {
      p.name = paramNamer.makeUnique(p.name);
    }

    final cType = _exposedFunctionTypealias?.getCType(w) ??
        functionType.getCType(w, writeArgumentNames: false);
    final dartType = _exposedFunctionTypealias?.getFfiDartType(w) ??
        functionType.getFfiDartType(w, writeArgumentNames: false);

    if (ffiNativeConfig.enabled) {
      final assetString = ffiNativeConfig.asset != null
          ? ", asset: '${ffiNativeConfig.asset}'"
          : '';
      final isLeafString = isLeaf ? ', isLeaf: true' : '';
      s.write(
          "@${w.ffiLibraryPrefix}.Native<$cType>(symbol: '$originalName'$assetString$isLeafString)\n");

      s.write(
          'external ${functionType.returnType.getFfiDartType(w)} $enclosingFuncName(\n');
      for (final p in functionType.dartTypeParameters) {
        s.write('  ${p.type.getFfiDartType(w)} ${p.name},\n');
      }
      s.write(');\n\n');
    } else {
      // Write enclosing function.
      s.write(
          '${functionType.returnType.getFfiDartType(w)} $enclosingFuncName(\n');
      for (final p in functionType.dartTypeParameters) {
        s.write('  ${p.type.getFfiDartType(w)} ${p.name},\n');
      }
      s.write(') {\n');
      s.write('return $funcVarName');

      s.write('(\n');
      for (final p in functionType.dartTypeParameters) {
        s.write('    ${p.name},\n');
      }
      s.write('  );\n');
      s.write('}\n');

      if (exposeSymbolAddress) {
        // Add to SymbolAddress in writer.
        w.symbolAddressWriter.addSymbol(
          type:
              '${w.ffiLibraryPrefix}.Pointer<${w.ffiLibraryPrefix}.NativeFunction<$cType>>',
          name: name,
          ptrName: funcPointerName,
        );
      }
      // Write function pointer.
      s.write(
          "late final $funcPointerName = ${w.lookupFuncIdentifier}<${w.ffiLibraryPrefix}.NativeFunction<$cType>>('$originalName');\n");
      final isLeafString = isLeaf ? 'isLeaf:true' : '';
      s.write(
          'late final $funcVarName = $funcPointerName.asFunction<$dartType>($isLeafString);\n\n');
    }

    return BindingString(type: BindingStringType.func, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    functionType.addDependencies(dependencies);
    if (exposeFunctionTypedefs) {
      _exposedFunctionTypealias!.addDependencies(dependencies);
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
        // A [NativeFunc] is wrapped with a pointer because this is a shorthand
        // used in C for Pointer to function.
        type = type.typealiasType is NativeFunc ? PointerType(type) : type;
}
