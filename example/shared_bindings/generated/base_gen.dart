// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to `headers/base.h`.
class NativeLibraryBase {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibraryBase(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibraryBase.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void base_func1(
    BaseTypedef1 t1,
    BaseTypedef2 t2,
  ) {
    return _base_func1(
      t1,
      t2,
    );
  }

  late final _base_func1Ptr = _lookup<
          ffi.NativeFunction<ffi.Void Function(BaseTypedef1, BaseTypedef2)>>(
      'base_func1');
  late final _base_func1 =
      _base_func1Ptr.asFunction<void Function(BaseTypedef1, BaseTypedef2)>();
}

class BaseStruct1 extends ffi.Struct {
  @ffi.Int()
  external int a;
}

class BaseUnion1 extends ffi.Union {
  @ffi.Int()
  external int a;
}

class BaseStruct2 extends ffi.Struct {
  @ffi.Int()
  external int a;
}

class BaseUnion2 extends ffi.Union {
  @ffi.Int()
  external int a;
}

abstract class BaseEnum {
  static const int BASE_ENUM_1 = 0;
  static const int BASE_ENUM_2 = 1;
}

typedef BaseTypedef1 = BaseStruct1;
typedef BaseTypedef2 = BaseStruct2;

const int BASE_MACRO_1 = 1;
