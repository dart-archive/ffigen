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

    builtInFunctions.ensureBlockUtilsExist(w, s);

    final params = <Parameter>[];
    for (int i = 0; i < argTypes.length; ++i) {
      params.add(Parameter(name: 'arg$i', type: argTypes[i]));
    }

    final isVoid = returnType == voidType;
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
    final natTrampFnType = NativeFunc(trampFuncType);
    final nativeCallableType =
        '${w.ffiLibraryPrefix}.NativeCallable<${trampFuncType.getCType(w)}>';

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
    final defaultValue = returnType.getDefaultValue(w, '_lib');
    final exceptionalReturn = defaultValue == null ? '' : ', $defaultValue';
    s.write('''
class $name extends _ObjCBlockBase {
  $name._(${blockPtr.getCType(w)} id, ${w.className} lib) :
      super._(id, lib, retain: false, release: true);

  /// Creates a block from a C function pointer.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  $name.fromFunctionPointer(${w.className} lib, $natFnPtr ptr) :
      this._(lib.${builtInFunctions.newBlock.name}(
          _cFuncTrampoline ??= ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              ${trampFuncType.getCType(w)}>($funcPtrTrampoline
                  $exceptionalReturn).cast(), ptr.cast()), lib);
  static $voidPtr? _cFuncTrampoline;

  /// Creates a block from a Dart function.
  ///
  /// This block must be invoked by native code running on the same thread as
  /// the isolate that registered it. Invoking the block on the wrong thread
  /// will result in a crash.
  $name.fromFunction(${w.className} lib, ${funcType.getDartType(w)} fn) :
      this._(lib.${builtInFunctions.newBlock.name}(
          _dartFuncTrampoline ??= ${w.ffiLibraryPrefix}.Pointer.fromFunction<
              ${trampFuncType.getCType(w)}>($closureTrampoline
                  $exceptionalReturn).cast(), $registerClosure(fn)), lib);
  static $voidPtr? _dartFuncTrampoline;

''');

    // Listener block constructor is only available for void blocks.
    if (isVoid) {
      s.write('''
  /// Creates a listener block from a Dart function.
  ///
  /// This is based on FFI's NativeCallable.listener, and has the same
  /// capabilities and limitations. This block can be invoked from any thread,
  /// but only supports void functions, and is not run synchronously. See
  /// NativeCallable.listener for more details.
  ///
  /// Note that unlike the default behavior of NativeCallable.listener, listener
  /// blocks do not keep the isolate alive.
  $name.listener(${w.className} lib, ${funcType.getDartType(w)} fn) :
      this._(lib.${builtInFunctions.newBlock.name}(
          (_dartFuncListenerTrampoline ??= $nativeCallableType.listener($closureTrampoline
                  $exceptionalReturn)..keepIsolateAlive = false).nativeFunction.cast(),
          $registerClosure(fn)), lib);
  static $nativeCallableType? _dartFuncListenerTrampoline;

''');
    }

    // Call method.
    s.write('  ${returnType.getDartType(w)} call(');
    for (int i = 0; i < params.length; ++i) {
      s.write('${i == 0 ? '' : ', '}${params[i].type.getDartType(w)}');
      s.write(' ${params[i].name}');
    }
    s.write(''') {
    ${isVoid ? '' : 'return '}_id.ref.invoke.cast<
        ${natTrampFnType.getCType(w)}>().asFunction<
            ${trampFuncType.getDartType(w)}>()(_id''');
    for (int i = 0; i < params.length; ++i) {
      s.write(', ${params[i].name}');
    }
    s.write(''');
  }''');

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
    builtInFunctions.addBlockDependencies(dependencies);
  }

  @override
  String getCType(Writer w) =>
      PointerType(builtInFunctions.blockStruct).getCType(w);

  @override
  String toString() => '($returnType (^)(${argTypes.join(', ')}))';
}
