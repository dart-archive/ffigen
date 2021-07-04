// ignore_for_file: camel_case_types

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:wasmjsgen`.
import 'dart:ffi' as ffi;

/// Functions Test
class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void func1() {
    return _func1();
  }

  late final _func1Ptr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('func1');
  late final _func1 = _func1Ptr.asFunction<void Function()>();

  int func2(
    int arg0,
  ) {
    return _func2(
      arg0,
    );
  }

  late final _func2Ptr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int16)>>('func2');
  late final _func2 = _func2Ptr.asFunction<int Function(int)>();

  double func3(
    double arg0,
    int a,
    int arg2,
    int b,
  ) {
    return _func3(
      arg0,
      a,
      arg2,
      b,
    );
  }

  late final _func3Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Double Function(
              ffi.Float, ffi.Int8, ffi.Int64, ffi.Int32)>>('func3');
  late final _func3 =
      _func3Ptr.asFunction<double Function(double, int, int, int)>();

  ffi.Pointer<ffi.Void> func4(
    ffi.Pointer<ffi.Pointer<ffi.Int8>> arg0,
    double arg1,
    ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Int32>>> arg2,
  ) {
    return _func4(
      arg0,
      arg1,
      arg2,
    );
  }

  late final _func4Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<ffi.Pointer<ffi.Int8>>,
              ffi.Double,
              ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Int32>>>)>>('func4');
  late final _func4 = _func4Ptr.asFunction<
      ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Pointer<ffi.Int8>>, double,
          ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Int32>>>)>();

  void func5(
    ffi.Pointer<shortHand> a,
    ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>> b,
  ) {
    return _func5(
      a,
      b,
    );
  }

  late final _func5Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<shortHand>,
              ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>>('func5');
  late final _func5 = _func5Ptr.asFunction<
      void Function(ffi.Pointer<shortHand>,
          ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>();

  late final addresses = _SymbolAddresses(this);
}

class _SymbolAddresses {
  final NativeLibrary _library;
  _SymbolAddresses(this._library);
  ffi.Pointer<
          ffi.NativeFunction<
              ffi.Double Function(ffi.Float, ffi.Int8, ffi.Int64, ffi.Int32)>>
      get func3 => _library._func3Ptr;
  ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<ffi.Pointer<ffi.Int8>>,
              ffi.Double,
              ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Int32>>>)>> get func4 =>
      _library._func4Ptr;
}

typedef shortHand = ffi.NativeFunction<
    ffi.Void Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>;
