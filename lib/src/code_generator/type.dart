// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';

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

  /// Represents an imported type.
  ImportedType,

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

  /// Placeholder for a type in a cache. Once the entry is fully filled in,
  /// the types child will point to the real type, and the cache entry should be
  /// considered exactly equivalent to the wrapped type.
  CacheEntry,
}

/// Type class for return types, variable types, etc.
class Type {
  static const _primitives = <SupportedNativeType, _SubType>{
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

  /// Reference to the [ImportedType] this type refers to.
  ImportedType? importedType;

  /// For providing [SupportedNativeType] only.
  final SupportedNativeType? nativeType;

  /// The BroadType of this Type.
  final BroadType broadType;

  /// Child Type, e.g Pointer(Parent) to Int(Child), Child Type of an Array, or
  /// the type that a CacheEntry points to.
  Type? child;

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
    this.importedType,
    this.length,
    this.unimplementedReason,
  });

  factory Type.pointer(Type child) =>
      Type._(broadType: BroadType.Pointer, child: child);
  factory Type.compound(Compound compound) =>
      Type._(broadType: BroadType.Compound, compound: compound);
  factory Type.struct(Struc struc) =>
      Type._(broadType: BroadType.Compound, compound: struc);
  factory Type.union(Union union) =>
      Type._(broadType: BroadType.Compound, compound: union);
  factory Type.enumClass(EnumClass enumClass) =>
      Type._(broadType: BroadType.Enum, enumClass: enumClass);
  factory Type.functionType(FunctionType functionType) =>
      Type._(broadType: BroadType.FunctionType, functionType: functionType);
  factory Type.importedType(ImportedType importedType) =>
      Type._(broadType: BroadType.ImportedType, importedType: importedType);
  factory Type.nativeFunc(NativeFunc nativeFunc) =>
      Type._(broadType: BroadType.NativeFunction, nativeFunc: nativeFunc);
  factory Type.typealias(Typealias typealias) =>
      Type._(broadType: BroadType.Typealias, typealias: typealias);
  factory Type.nativeType(SupportedNativeType nativeType) =>
      Type._(broadType: BroadType.NativeType, nativeType: nativeType);
  factory Type.constantArray(int length, Type elementType) => Type._(
        broadType: BroadType.ConstantArray,
        child: elementType,
        length: length,
      );
  factory Type.incompleteArray(Type elementType) => Type._(
        broadType: BroadType.IncompleteArray,
        child: elementType,
      );
  factory Type.boolean() => Type._(
        broadType: BroadType.Boolean,
      );
  factory Type.unimplemented(String reason) =>
      Type._(broadType: BroadType.Unimplemented, unimplementedReason: reason);
  factory Type.handle() => Type._(broadType: BroadType.Handle);
  factory Type.cacheEntry() => Type._(broadType: BroadType.CacheEntry);

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
        broadType == BroadType.IncompleteArray ||
        broadType == BroadType.CacheEntry) {
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
    } else if (broadType == BroadType.CacheEntry) {
      return child!.getBaseTypealiasType();
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

  /// If this is a filled [BroadType.CacheEntry], returns the wrapped type.
  /// Otherwise returns this type.
  Type? get cachedType => broadType == BroadType.CacheEntry
      ? child?.cachedType
      : this;

  /// Returns false if this is an unfilled [BroadType.CacheEntry]. Otherwise
  /// returns true.
  bool get isCacheEntryFilled =>
      broadType == BroadType.CacheEntry ? child != null : true;

  String getCType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return '${w.ffiLibraryPrefix}.${_primitives[nativeType!]!.c}';
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child!.getCType(w)}>';
      case BroadType.Compound:
        return compound!.name;
      case BroadType.Enum:
        return '${w.ffiLibraryPrefix}.${_primitives[enumNativeType]!.c}';
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFunc!.type.getCType(w)}>';
      case BroadType
          .IncompleteArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child!.getCType(w)}>';
      case BroadType
          .ConstantArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child!.getCType(w)}>';
      case BroadType.Boolean: // Booleans are treated as uint8.
        return '${w.ffiLibraryPrefix}.${_primitives[SupportedNativeType.Uint8]!.c}';
      case BroadType.Handle:
        return '${w.ffiLibraryPrefix}.Handle';
      case BroadType.FunctionType:
        return functionType!.getCType(w);
      case BroadType.ImportedType:
        return '${importedType!.libraryImport.prefix}.${importedType!.cType}';
      case BroadType.Typealias:
        return typealias!.name;
      case BroadType.CacheEntry:
        return cachedType!.getCType(w);
      case BroadType.Unimplemented:
        throw UnimplementedError('C type unknown for ${broadType.toString()}');
    }
  }

  String getDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return _primitives[nativeType!]!.dart;
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child!.getCType(w)}>';
      case BroadType.Compound:
        return compound!.name;
      case BroadType.Enum:
        return _primitives[enumNativeType]!.dart;
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFunc!.type.getDartType(w)}>';
      case BroadType
          .IncompleteArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child!.getCType(w)}>';
      case BroadType
          .ConstantArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child!.getCType(w)}>';
      case BroadType.Boolean: // Booleans are treated as uint8.
        return _primitives[SupportedNativeType.Uint8]!.dart;
      case BroadType.Handle:
        return 'Object';
      case BroadType.FunctionType:
        return functionType!.getDartType(w);
      case BroadType.ImportedType:
        if (importedType!.cType == importedType!.dartType) {
          return getCType(w);
        } else {
          return importedType!.dartType;
        }
      case BroadType.Typealias:
        // Typealias cannot be used by name in Dart types unless both the C and
        // Dart type of the underlying types are same.
        if (typealias!.type.sameDartAndCType(w)) {
          return typealias!.name;
        } else {
          return typealias!.type.getDartType(w);
        }
      case BroadType.CacheEntry:
        return cachedType!.getDartType(w);
      case BroadType.Unimplemented:
        throw UnimplementedError(
            'dart type unknown for ${broadType.toString()}');
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
