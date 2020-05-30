import 'package:meta/meta.dart';

import 'constants.dart';

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
}

enum FfiUtilType {
  Utf8,
  Utf16,
}

enum BroadType {
  NativeType,
  FfiUtilType,
  Pointer,
  Struct,
  NativeFunction,
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
    //TODO: check float32,64
    SupportedNativeType.Float32: _SubType(c: 'Float', dart: 'double'),
    SupportedNativeType.Float64: _SubType(c: 'Double', dart: 'double'),
    SupportedNativeType.Double: _SubType(c: 'Double', dart: 'double'),
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

  Type({
    @required this.type,
    this.child,
    this.structName,
    this.nativeType,
    this.ffiUtilType,
    this.nativeFuncName,
  });

  bool get isPrimitive => type == BroadType.NativeType;

  String get cType {
    switch (type) {
      case BroadType.NativeType:
        return '$ffiLibraryPrefix.${_primitives[nativeType].c}';
      case BroadType.FfiUtilType:
        return '$ffiUtilLibPrefix.${_ffiUtils[ffiUtilType].c}';
      case BroadType.Pointer:
        return '$ffiLibraryPrefix.Pointer<${child.cType}>';
      case BroadType.Struct:
        return structName;
      case BroadType.NativeFunction:
        return '$ffiLibraryPrefix.NativeFunction<${nativeFuncName}>';
      default:
        throw Exception('cType unknown');
    }
  }

  String get dartType {
    switch (type) {
      case BroadType.NativeType:
        return _primitives[nativeType].dart;
      case BroadType.Pointer:
        return '$ffiLibraryPrefix.Pointer<${child.cType}>';
      case BroadType.Struct:
        return structName;
      case BroadType.NativeFunction:
        return '$ffiLibraryPrefix.NativeFunction<${nativeFuncName}>';
      // TODO: check ffiUtilType doesn't have a dart type, it can only be inside a Pointer which redirects it to its c type
      default:
        throw Exception('dart type unknown for ${type.toString()}');
    }
  }

  @override
  String toString() {
    return 'Type: ${type}, varName: ${structName}';
  }
}
