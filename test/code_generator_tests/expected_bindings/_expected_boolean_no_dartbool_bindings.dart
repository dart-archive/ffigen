// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

class Bindings {
  /// Holds the Dynamic library.
  final ffi.DynamicLibrary _dylib;

  /// The symbols are looked up in [dynamicLibrary].
  Bindings(ffi.DynamicLibrary dynamicLibrary) : _dylib = dynamicLibrary;

  int test1(
    int a,
    ffi.Pointer<ffi.Uint8> b,
  ) {
    return (_test1 ??= _dylib.lookupFunction<_c_test1, _dart_test1>('test1'))(
      a,
      b,
    );
  }

  _dart_test1? _test1;
}

class test2 extends ffi.Struct {
  @ffi.Uint8()
  external int a;
}

typedef _c_test1 = ffi.Uint8 Function(
  ffi.Uint8 a,
  ffi.Pointer<ffi.Uint8> b,
);

typedef _dart_test1 = int Function(
  int a,
  ffi.Pointer<ffi.Uint8> b,
);
