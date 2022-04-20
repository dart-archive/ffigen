// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

import 'binding_string.dart';
import 'utils.dart';
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
    final blockPtr = PointerType(builtInFunctions.blockStruct).getCType(w);
    final funcType = FunctionType(returnType: returnType, parameters: params);
    final natFnPtr = PointerType(NativeFunc(funcType)).getCType(w);
    final funcPtrTrampoline =
        w.topLevelUniqueNamer.makeUnique('_${name}_fnPtrTrampoline');

    // Write the function pointer based trampoline function.
    s.write(returnType.getCType(w));
    s.write(' $funcPtrTrampoline($blockPtr block');
    for (int i = 0; i < params.length; ++i) {
      s.write(', ${params[i].type.getCType(w)} ${params[i].name}');
    }
    s.write(') {\n');
    s.write('  ${isVoid ? '' : 'return '}block.target.asFunction<'
        '${funcType.getCType(w)}>(');
    for (int i = 0; i < params.length; ++i) {
      s.write('${i == 0 ? '' : ', '}${params[i].name}');
    }
    s.write(');\n');
    s.write('}\n');

    // Write the wrapper class.
    s.write('class $name {\n');

    s.write('  final $blockPtr _impl;\n');
    s.write('  final ${w.className} _lib;\n');

    // Constructor from a function pointer.
    s.write('\n');
    s.write('  $name.fromFunctionPointer(this._lib, $natFnPtr ptr, '
        '[Object? exceptionalReturn])');
    s.write(' : _impl =  _lib.${builtInFunctions.newBlock.name}('
        'Pointer.fromFunction($funcPtrTrampoline, exceptionalReturn), '
        'ptr){}\n');
    
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

    builtInFunctions.blockStruct.addDependencies(dependencies);
    builtInFunctions.blockDescSingleton.addDependencies(dependencies);
    builtInFunctions.newBlockDesc.addDependencies(dependencies);
    builtInFunctions.newBlock.addDependencies(dependencies);
  }

  @override
  String getCType(Writer w) => PointerType(objCObjectType).getCType(w);

  @override
  String toString() {
    return 'block';
  }
}
