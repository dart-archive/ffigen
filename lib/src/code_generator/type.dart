import 'package:meta/meta.dart';

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
  Float32,
  Float64,
  Double,
  IntPtr,
}

enum FfiUtilType {
  Utf8,
  Utf16,
}

/// The basic types in which all types can be classified
enum BroadType {
  NativeType,
  FfiUtilType,
  Pointer,
  Struct,
  NativeFunction,

  /// stores its element type in NativeType as only those are supported
  Array,
}

/// Type class for return types, variable types, etc
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
    //TODO: check float32,64
    SupportedNativeType.Float32: _SubType(c: 'Float', dart: 'double'),
    SupportedNativeType.Float64: _SubType(c: 'Double', dart: 'double'),
  };

  static const _ffiUtils = <FfiUtilType, _SubType>{
    FfiUtilType.Utf8: _SubType(c: 'Utf8', dart: 'Utf8'),
    FfiUtilType.Utf16: _SubType(c: 'Utf16', dart: 'Utf16'),
  };

  /// For providing name of Struct
  String structName;

  String nativeFuncName;

  /// For providing [SupportedNativeType] only
  final SupportedNativeType nativeType;

  /// For providing [FfiUtilType] only
  final FfiUtilType ffiUtilType;

  /// The BroadType of this Type
  final BroadType type;

  /// Child Type, e.g Pointer(Parent) to Int(Child)
  final Type child;

  Type._({
    @required this.type,
    this.child,
    this.structName,
    this.nativeType,
    this.ffiUtilType,
    this.nativeFuncName,
  });

  factory Type.pointer(Type child) {
    return Type._(type: BroadType.Pointer, child: child);
  }
  factory Type.struct(String structName) {
    return Type._(type: BroadType.Struct, structName: structName);
  }
  factory Type.nativeFunc(String nativeFuncName) {
    return Type._(
        type: BroadType.NativeFunction, nativeFuncName: nativeFuncName);
  }
  factory Type.nativeType(SupportedNativeType nativeType) {
    return Type._(type: BroadType.NativeType, nativeType: nativeType);
  }
  factory Type.ffiUtilType(FfiUtilType ffiUtilType) {
    return Type._(type: BroadType.FfiUtilType, ffiUtilType: ffiUtilType);
  }
  factory Type.array(SupportedNativeType nativeType) {
    return Type._(type: BroadType.Array, nativeType: nativeType);
  }

  bool get isPrimitive => type == BroadType.NativeType;

  String getCType(Writer w) {
    switch (type) {
      case BroadType.NativeType:
        return '${w.ffiLibraryPrefix}.${_primitives[nativeType].c}';
      case BroadType.FfiUtilType:
        return '${w.ffiUtilLibPrefix}.${_ffiUtils[ffiUtilType].c}';
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Struct:
        return structName;
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFuncName}>';
      default:
        throw Exception('cType unknown');
    }
  }

  String getDartType(Writer w) {
    switch (type) {
      case BroadType.NativeType:
        return _primitives[nativeType].dart;
      case BroadType.Pointer:
        return '${w.ffiLibraryPrefix}.Pointer<${child.getCType(w)}>';
      case BroadType.Struct:
        return structName;
      case BroadType.NativeFunction:
        return '${w.ffiLibraryPrefix}.NativeFunction<${nativeFuncName}>';
      // TODO: check- ffiUtilType doesn't have a dart type, it can only be inside a Pointer which redirects it to its c type
      default:
        throw Exception('dart type unknown for ${type.toString()}');
    }
  }

  @override
  String toString() {
    return 'Type: ${type}';
  }
}
