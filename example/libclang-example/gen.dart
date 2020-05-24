/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

class CXString extends ffi.Struct {}

class CXUnsavedFile extends ffi.Struct {}

ffi.Pointer<ffi2.Utf8> clang_getCString_wrap(
  ffi.Pointer<CXString> string,
) {
  return _clang_getCString_wrap(
    string,
  );
}

final _dart_clang_getCString_wrap _clang_getCString_wrap = _dylib
    .lookupFunction<_c_clang_getCString_wrap, _dart_clang_getCString_wrap>(
        'clang_getCString_wrap');

typedef _c_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> string,
);

typedef _dart_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> string,
);
