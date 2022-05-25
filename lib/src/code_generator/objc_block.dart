// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'writer.dart';

class ObjCBlock extends BindingType {
  final Type returnType;
  final List<Type> argTypes;
  final ObjCBuiltInFunctions builtInFunctions;

  ObjCBlock({
    required String usr,
    required String name,
    required this.returnType,
    required this.argTypes,
    required this.builtInFunctions,
  }) : super(
          usr: usr,
          originalName: name,
          name: name,
        );

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    final params = <Parameter>[];
    for (int i = 0; i < argTypes.length; ++i) {
      params.add(Parameter(name: 'arg$i', type: argTypes[i]));
    }

    final isVoid = returnType == NativeType(SupportedNativeType.Void);
    final voidPtr = PointerType(voidType).getCType(w);
    final blockPtr = PointerType(builtInFunctions.blockStruct);
    final funcType = FunctionType(returnType: returnType, parameters: params);
    final natFnType = NativeFunc(funcType);
    final natFnPtr = PointerType(natFnType).getCType(w);
    final funcPtrTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_fnPtrTrampoline');
    final closureTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_closureTrampoline');
    final registerClosure =
        w.topLevelUniqueNamer.makeUnique('_${name}_registerClosure');
    final closureRegistry =
        w.topLevelUniqueNamer.makeUnique('_${name}_closureRegistry');
    final closureRegistryIndex =
        w.topLevelUniqueNamer.makeUnique('_${name}_closureRegistryIndex');
    final trampFuncType = FunctionType(
        returnType: returnType,
        parameters: [Parameter(type: blockPtr, name: 'block'), ...params]);

    // Write the function pointer based trampoline function.
    s.write(returnType.getDartType(w));
    s.write(' $funcPtrTrampoline(${blockPtr.getCType(w)} block');
    for (int i = 0; i < params.length; ++i) {
      s.write(', ${params[i].type.getDartType(w)} ${params[i].name}');
    }
    s.write(') {\n');
    s.write('  ${isVoid ? '' : 'return '}block.ref.target.cast<'
        '${natFnType.getDartType(w)}>().asFunction<'
        '${funcType.getDartType(w)}>()(');
    for (int i = 0; i < params.length; ++i) {
      s.write('${i == 0 ? '' : ', '}${params[i].name}');
    }
    s.write(');\n');
    s.write('}\n');

    // Write the closure registry function.
    s.write('''
final $closureRegistry = <int, Function>{};
int $closureRegistryIndex = 0;
$voidPtr $registerClosure(Function fn) {
  final id = ++$closureRegistryIndex;
  $closureRegistry[id] = fn;
  return $voidPtr.fromAddress(id);
}
''');

    // Write the closure based trampoline function.
    s.write(returnType.getDartType(w));
    s.write(' $closureTrampoline(${blockPtr.getCType(w)} block');
    for (int i = 0; i < params.length; ++i) {
      s.write(', ${params[i].type.getDartType(w)} ${params[i].name}');
    }
    s.write(') {\n');
    s.write('  ${isVoid ? '' : 'return '}$closureRegistry['
        'block.ref.target.address]!(');
    for (int i = 0; i < params.length; ++i) {
      s.write('${i == 0 ? '' : ', '}${params[i].name}');
    }
    s.write(');\n');
    s.write('}\n');

    // Write the wrapper class.
    s.write('class $name {\n');
    s.write('  final ${blockPtr.getCType(w)} _impl;\n');
    s.write('  final ${w.className} _lib;\n');
    s.write('  $name._(this._impl, this._lib);\n');

    // Constructor from a function pointer.
    final defaultValue = returnType.getDefaultValue(w, '_lib');
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';
    s.write('''
  $name.fromFunctionPointer(this._lib, $natFnPtr ptr)
      : _impl =  _lib.${builtInFunctions.newBlock.name}(
          ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              ${trampFuncType.getCType(w)}>($funcPtrTrampoline
                  $exceptionalReturn).cast(), ptr.cast());
  $name.fromFunction(this._lib, ${funcType.getDartType(w)} fn)
      : _impl =  _lib.${builtInFunctions.newBlock.name}(
          ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              ${trampFuncType.getCType(w)}>($closureTrampoline
                  $exceptionalReturn).cast(), $registerClosure(fn));
''');

    // Get the pointer to the underlying block.
    s.write('  ${blockPtr.getCType(w)} get pointer => _impl;\n');

    s.write('}\n');
    return BindingString(
        type: BindingStringType.objcBlock, string: s.toString());
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;
    dependencies.add(this);

    returnType.addDependencies(dependencies);
    for (final t in argTypes) {
      t.addDependencies(dependencies);
    }

    builtInFunctions.newBlockDesc.addDependencies(dependencies);
    builtInFunctions.blockDescSingleton.addDependencies(dependencies);
    builtInFunctions.blockStruct.addDependencies(dependencies);
    builtInFunctions.concreteGlobalBlock.addDependencies(dependencies);
    builtInFunctions.newBlock.addDependencies(dependencies);
  }

  @override
  String getCType(Writer w) =>
      PointerType(builtInFunctions.blockStruct).getCType(w);

  @override
  String toString() => '($returnType (^)(${argTypes.join(', ')}))';
}
