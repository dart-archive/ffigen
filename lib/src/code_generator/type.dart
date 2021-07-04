// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:wasmjsgen/src/code_generator.dart';

import 'compound.dart';
import 'typealias.dart';
import 'writer.dart';

class _SubType {
  final String c;
  final String dart;

  const _SubType({required this.c, required this.dart});
}

enum SupportedNativeType {
  Void,
  Char,
  Int8,
  Int16,
  Int32,
  Int64,
  Uint8,
  Uint16,
  Uint32,
  Uint64,
  Float,
  Double,
  IntPtr,
}

/// The basic types in which all types can be broadly classified into.
enum BroadType {
  Boolean,
  NativeType,
  Pointer,
  Compound,
  NativeFunction,

  /// Represents a function type.
  FunctionType,

  /// Represents a typealias.
  Typealias,

  /// Represents a Dart_Handle.
  Handle,

  Enum,

  /// Represents an Array type.
  ConstantArray,
  IncompleteArray,

  /// Used as a marker, so that declarations having these can exclude them.
  Unimplemented,
}

bool isJsBigInt(SupportedNativeType nativeType) {
  switch (nativeType) {
    case SupportedNativeType.Int64:
    case SupportedNativeType.Uint64:
      return true;
    default:
      return false;
  }
}

/// Type class for return types, variable types, etc.
class Type {
  static const primitives = <SupportedNativeType, _SubType>{
    SupportedNativeType.Void: _SubType(c: 'Void', dart: 'void'),
    SupportedNativeType.Char: _SubType(c: 'Uint8', dart: 'int'),
    SupportedNativeType.Int8: _SubType(c: 'Int8', dart: 'int'),
    SupportedNativeType.Int16: _SubType(c: 'Int16', dart: 'int'),
    SupportedNativeType.Int32: _SubType(c: 'Int32', dart: 'int'),
    SupportedNativeType.Int64: _SubType(c: 'Int64', dart: 'int'),
    SupportedNativeType.Uint8: _SubType(c: 'Uint8', dart: 'int'),
    SupportedNativeType.Uint16: _SubType(c: 'Uint16', dart: 'int'),
    SupportedNativeType.Uint32: _SubType(c: 'Uint32', dart: 'int'),
    SupportedNativeType.Uint64: _SubType(c: 'Uint64', dart: 'int'),
    SupportedNativeType.Float: _SubType(c: 'Float', dart: 'double'),
    SupportedNativeType.Double: _SubType(c: 'Double', dart: 'double'),
    SupportedNativeType.IntPtr: _SubType(c: 'IntPtr', dart: 'int'),
  };

  /// Enum type is mapped to [SupportedNativeType.Int32].
  static const enumNativeType = SupportedNativeType.Int32;

  /// Reference to the [Compound] binding this type refers to.
  Compound? compound;

  /// Reference to the [NativeFunc] this type refers to.
  NativeFunc? nativeFunc;

  /// Reference to the [Typealias] this type refers to.
  Typealias? typealias;

  /// Reference to the [FunctionType] this type refers to.
  FunctionType? functionType;

  /// Reference to the [EnumClass] this type refers to.
  EnumClass? enumClass;

  /// For providing [SupportedNativeType] only.
  final SupportedNativeType? nativeType;

  /// The BroadType of this Type.
  final BroadType broadType;

  /// Child Type, e.g Pointer(Parent) to Int(Child), or Child Type of an Array.
  final Type? child;

  /// For ConstantArray and IncompleteArray type.
  final int? length;

  /// For storing cursor type info for an unimplemented type.
  String? unimplementedReason;

  Type._({
    required this.broadType,
    this.child,
    this.compound,
    this.enumClass,
    this.nativeType,
    this.nativeFunc,
    this.typealias,
    this.functionType,
    this.length,
    this.unimplementedReason,
  });

  factory Type.pointer(Type child) {
    return Type._(broadType: BroadType.Pointer, child: child);
  }
  factory Type.compound(Compound compound) {
    return Type._(broadType: BroadType.Compound, compound: compound);
  }
  factory Type.struct(Struc struc) {
    return Type._(broadType: BroadType.Compound, compound: struc);
  }
  factory Type.union(Union union) {
    return Type._(broadType: BroadType.Compound, compound: union);
  }
  factory Type.enumClass(EnumClass enumClass) {
    return Type._(broadType: BroadType.Enum, enumClass: enumClass);
  }
  factory Type.functionType(FunctionType functionType) {
    return Type._(
        broadType: BroadType.FunctionType, functionType: functionType);
  }
  factory Type.nativeFunc(NativeFunc nativeFunc) {
    return Type._(broadType: BroadType.NativeFunction, nativeFunc: nativeFunc);
  }
  factory Type.typealias(Typealias typealias) {
    return Type._(broadType: BroadType.Typealias, typealias: typealias);
  }
  factory Type.nativeType(SupportedNativeType nativeType) {
    return Type._(broadType: BroadType.NativeType, nativeType: nativeType);
  }
  factory Type.constantArray(int length, Type elementType) {
    return Type._(
      broadType: BroadType.ConstantArray,
      child: elementType,
      length: length,
    );
  }
  factory Type.incompleteArray(Type elementType) {
    return Type._(
      broadType: BroadType.IncompleteArray,
      child: elementType,
    );
  }
  factory Type.boolean() {
    return Type._(
      broadType: BroadType.Boolean,
    );
  }
  factory Type.unimplemented(String reason) {
    return Type._(
        broadType: BroadType.Unimplemented, unimplementedReason: reason);
  }
  factory Type.handle() {
    return Type._(broadType: BroadType.Handle);
  }

  /// Get all dependencies of this type and save them in [dependencies].
  void addDependencies(Set<Binding> dependencies) {
    switch (broadType) {
      case BroadType.Compound:
        return compound!.addDependencies(dependencies);
      case BroadType.NativeFunction:
        return nativeFunc!.addDependencies(dependencies);
      case BroadType.FunctionType:
        return functionType!.addDependencies(dependencies);
      case BroadType.Typealias:
        return typealias!.addDependencies(dependencies);
      case BroadType.Enum:
        return enumClass!.addDependencies(dependencies);
      default:
        if (child != null) {
          return child!.addDependencies(dependencies);
        }
    }
  }

  /// Get base type for any type.
  ///
  /// E.g int** has base [Type] of int.
  /// double[2][3] has base [Type] of double.
  Type getBaseType() {
    if (child != null) {
      return child!.getBaseType();
    } else {
      return this;
    }
  }

  /// Get base Array type.
  ///
  /// Returns itself if it's not an Array Type.
  Type getBaseArrayType() {
    if (broadType == BroadType.ConstantArray ||
        broadType == BroadType.IncompleteArray) {
      return child!.getBaseArrayType();
    } else {
      return this;
    }
  }

  /// Get base typealias type.
  ///
  /// Returns itself if it's not a Typealias.
  Type getBaseTypealiasType() {
    if (broadType == BroadType.Typealias) {
      return typealias!.type.getBaseTypealiasType();
    } else {
      return this;
    }
  }

  /// Function to check if the dart and C type string are same.
  bool sameDartAndCType(Writer w) => getCType(w) == getDartType(w);

  /// Returns true if the type is a [Compound] and is incomplete.
  bool get isIncompleteCompound {
    final baseTypealiasType = getBaseTypealiasType();
    if (baseTypealiasType == this) {
      return (broadType == BroadType.Compound &&
              compound != null &&
              compound!.isInComplete) ||
          (broadType == BroadType.ConstantArray &&
              getBaseArrayType().isIncompleteCompound);
    } else {
      return baseTypealiasType.isIncompleteCompound;
    }
  }

  String getCType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return Type.primitives[nativeType!]!.c;
      case BroadType.Pointer:
        return 'Pointer<${child!.getCType(w)}>';
      case BroadType.Compound:
        return compound!.name;
      case BroadType.Enum:
        return Type.primitives[Type.enumNativeType]!.c;
      case BroadType.NativeFunction:
        return 'NativeFunction<${nativeFunc!.type.getCType(w)}>';
      case BroadType
          .IncompleteArray: // Array parameters are treated as Pointers in C.
        return 'Pointer<${child!.getCType(w)}>';
      case BroadType
          .ConstantArray: // Array parameters are treated as Pointers in C.
        return 'Pointer<${child!.getCType(w)}>';
      case BroadType.Boolean: // Booleans are treated as uint8.
        return Type.primitives[SupportedNativeType.Uint8]!.c;
      case BroadType.Handle:
        return 'Handle';
      case BroadType.FunctionType:
        return functionType!.getCType(w);
      case BroadType.Typealias:
        return typealias!.name;
      case BroadType.Unimplemented:
        throw UnimplementedError('C type unknown for ${broadType.toString()}');
    }
  }

  String getDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return primitives[nativeType!]!.dart;
      case BroadType.Pointer:
        return 'Pointer<${child!.getCType(w)}>';
      case BroadType.Compound:
        return compound!.name;
      case BroadType.Enum:
        return primitives[enumNativeType]!.dart;
      case BroadType.NativeFunction:
        return 'NativeFunction<${nativeFunc!.type.getDartType(w)}>';
      case BroadType
          .IncompleteArray: // Array parameters are treated as Pointers in C.
        return 'Pointer<${child!.getCType(w)}>';
      case BroadType
          .ConstantArray: // Array parameters are treated as Pointers in C.
        return 'Pointer<${child!.getCType(w)}>';
      case BroadType.Boolean: // Booleans are treated as uint8.
        return primitives[SupportedNativeType.Uint8]!.dart;
      case BroadType.Handle:
        return 'Object';
      case BroadType.FunctionType:
        return functionType!.getDartType(w);
      case BroadType.Typealias:
        // Typealias cannot be used by name in Dart types unless both the C and
        // Dart type of the underlying types are same.
        if (typealias!.type.sameDartAndCType(w)) {
          return typealias!.name;
        } else {
          return typealias!.type.getDartType(w);
        }
      case BroadType.Unimplemented:
        throw UnimplementedError(
            'dart type unknown for ${broadType.toString()}');
    }
  }

  String getLookupDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return isJsBigInt(nativeType!) ? w.jsBigInt : getDartType(w);
      case BroadType.Pointer:
        return Type.nativeType(SupportedNativeType.Int32).getDartType(w);
      case BroadType.Compound:
      case BroadType.Enum:
      case BroadType.NativeFunction:
      case BroadType.IncompleteArray:
      case BroadType.ConstantArray:
      case BroadType.Boolean:
      case BroadType.Handle:
      case BroadType.FunctionType:
        return getDartType(w);
      case BroadType.Typealias:
        return typealias!.type.getLookupDartType(w);
      case BroadType.Unimplemented:
        return getDartType(w);
    }
  }

  String getParameterResolution(Writer w) {
    switch (broadType) {
      case BroadType.Pointer:
        return '.address';
      case BroadType.NativeType:
        return isJsBigInt(nativeType!) ? '.toString()' : '';
      case BroadType.Compound:
      case BroadType.Enum:
      case BroadType.NativeFunction:
      case BroadType.IncompleteArray:
      case BroadType.ConstantArray:
        return '';
      case BroadType.Boolean:
        return w.dartBool ? '? 1 : 0' : '';
      case BroadType.Handle:
      case BroadType.FunctionType:
        return '';
      case BroadType.Typealias:
        return typealias!.type.getParameterResolution(w);
      case BroadType.Unimplemented:
        return '';
    }
  }

  String getReturnWrapOpen(Writer w) {
    switch (broadType) {
      case BroadType.Pointer:
        return 'Pointer.fromAddress(${child!.getCType(w)}(';
      case BroadType.NativeType:
        return isJsBigInt(nativeType!) ? '${w.jsBigIntToInt}(' : '';
      case BroadType.Compound:
      case BroadType.Enum:
      case BroadType.NativeFunction:
      case BroadType.IncompleteArray:
      case BroadType.ConstantArray:
      case BroadType.Boolean:
      case BroadType.Handle:
      case BroadType.FunctionType:
        return '';
      case BroadType.Typealias:
        return typealias!.type.getReturnWrapOpen(w);
      case BroadType.Unimplemented:
        return '';
    }
  }

  String getReturnWrapClose(Writer w) {
    switch (broadType) {
      case BroadType.Pointer:
        return '),),';
      case BroadType.NativeType:
        return isJsBigInt(nativeType!) ? '),' : '';
      case BroadType.Compound:
      case BroadType.Enum:
      case BroadType.NativeFunction:
      case BroadType.IncompleteArray:
      case BroadType.ConstantArray:
        return '';
      case BroadType.Boolean:
        return w.dartBool ? ' != 0' : '';
      case BroadType.Handle:
      case BroadType.FunctionType:
        return '';
      case BroadType.Typealias:
        return typealias!.type.getReturnWrapClose(w);
      case BroadType.Unimplemented:
        return '';
    }
  }

  @override
  String toString() {
    return 'Type: $broadType';
  }
}

/// Represents a function type.
class FunctionType {
  final Type returnType;
  final List<Parameter> parameters;

  FunctionType({
    required this.returnType,
    required this.parameters,
  });

  String getCType(Writer w, {bool writeArgumentNames = true}) {
    final sb = StringBuffer();

    // Write return Type.
    sb.write(returnType.getCType(w));

    // Write Function.
    sb.write(' Function(');
    sb.write(parameters.map<String>((p) {
      return '${p.type.getCType(w)} ${writeArgumentNames ? p.name : ""}';
    }).join(', '));
    sb.write(')');

    return sb.toString();
  }

  String getDartType(Writer w, {bool writeArgumentNames = true}) {
    final sb = StringBuffer();

    // Write return Type.
    sb.write(returnType.getDartType(w));

    // Write Function.
    sb.write(' Function(');
    sb.write(parameters.map<String>((p) {
      return '${p.type.getDartType(w)} ${writeArgumentNames ? p.name : ""}';
    }).join(', '));
    sb.write(')');

    return sb.toString();
  }

  void addDependencies(Set<Binding> dependencies) {
    returnType.addDependencies(dependencies);
    for (final p in parameters) {
      p.type.addDependencies(dependencies);
    }
  }
}

/// Represents a NativeFunction<Function>.
class NativeFunc {
  final Type type;

  NativeFunc.fromFunctionType(FunctionType functionType)
      : type = Type.functionType(functionType);

  NativeFunc.fromFunctionTypealias(Typealias typealias)
      : type = Type.typealias(typealias);

  void addDependencies(Set<Binding> dependencies) {
    type.addDependencies(dependencies);
  }
}
