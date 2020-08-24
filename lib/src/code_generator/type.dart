// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'struc.dart';
import 'typedef.dart';
import 'writer.dart';

class _SubType {
  final String c;
  final String dart;

  const _SubType({this.c, this.dart});
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
  Struct,
  NativeFunction,

  /// Stores its element type in NativeType as only those are supported.
  ConstantArray,
  IncompleteArray,

  /// Used as a marker, so that functions/structs having these can exclude them.
  Unimplemented,
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

  /// Reference to the [Struc] binding this type refers to.
  Struc struc;

  /// Reference to the [Typedef] this type refers to.
  Typedef nativeFunc;

  /// For providing [SupportedNativeType] only.
  final SupportedNativeType nativeType;

  /// The BroadType of this Type.
  final BroadType broadType;

  /// Child Type, e.g Pointer(Parent) to Int(Child), or Child Type of an Array.
  final Type child;

  /// For ConstantArray and IncompleteArray type.
  final int length;

  /// For storing cursor type info for an unimplemented type.
  String unimplementedReason;

  Type._({
    @required this.broadType,
    this.child,
    this.struc,
    this.nativeType,
    this.nativeFunc,
    this.length,
    this.unimplementedReason,
  });

  factory Type.pointer(Type child) {
    return Type._(broadType: BroadType.Pointer, child: child);
  }
  factory Type.struct(Struc struc) {
    return Type._(broadType: BroadType.Struct, struc: struc);
  }
  factory Type.nativeFunc(Typedef nativeFunc) {
    return Type._(broadType: BroadType.NativeFunction, nativeFunc: nativeFunc);
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

  /// Get base type for any type.
  ///
  /// E.g int** has base [Type] of int.
  /// double[2][3] has base [Type] of double.
  Type getBaseType() {
    if (child != null) {
      return child.getBaseType();
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
      return child.getBaseArrayType();
    } else {
      return this;
    }
  }

  bool get isPrimitive =>
      (broadType == BroadType.NativeType || broadType == BroadType.Boolean);

  String getCType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return '${w.ffiLibraryPrefix}.${_primitives[nativeType].c}';
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Struct:
        return '${struc.name}';
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFunc.name}>';
      case BroadType
          .IncompleteArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType
          .ConstantArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Boolean: // Booleans are treated as uint8.
        return '${w.ffiLibraryPrefix}.${_primitives[SupportedNativeType.Uint8].c}';
      default:
        throw Exception('cType unknown');
    }
  }

  String getDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
        return _primitives[nativeType].dart;
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Struct:
        return '${struc.name}';
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFunc.name}>';
      case BroadType
          .IncompleteArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType
          .ConstantArray: // Array parameters are treated as Pointers in C.
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Boolean: // Booleans are treated as uint8.
        return _primitives[SupportedNativeType.Uint8].dart;
      default:
        throw Exception('dart type unknown for ${broadType.toString()}');
    }
  }

  @override
  String toString() {
    return 'Type: ${broadType}';
  }
}
