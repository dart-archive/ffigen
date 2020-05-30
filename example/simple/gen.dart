/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

int sum(
  int a,
  int b,
) {
  return _sum(
    a,
    b,
  );
}

final _dart_sum _sum = _dylib.lookupFunction<_c_sum, _dart_sum>('sum');

typedef _c_sum = ffi.Int32 Function(
  ffi.Int32 a,
  ffi.Int32 b,
);

typedef _dart_sum = int Function(
  int a,
  int b,
);

int subtract(
  ffi.Pointer<ffi.Int32> a,
  int b,
) {
  return _subtract(
    a,
    b,
  );
}

final _dart_subtract _subtract =
    _dylib.lookupFunction<_c_subtract, _dart_subtract>('subtract');

typedef _c_subtract = ffi.Int32 Function(
  ffi.Pointer<ffi.Int32> a,
  ffi.Int32 b,
);

typedef _dart_subtract = int Function(
  ffi.Pointer<ffi.Int32> a,
  int b,
);

ffi.Pointer<ffi.Int32> multiply(
  int a,
  int b,
) {
  return _multiply(
    a,
    b,
  );
}

final _dart_multiply _multiply =
    _dylib.lookupFunction<_c_multiply, _dart_multiply>('multiply');

typedef _c_multiply = ffi.Pointer<ffi.Int32> Function(
  ffi.Int32 a,
  ffi.Int32 b,
);

typedef _dart_multiply = ffi.Pointer<ffi.Int32> Function(
  int a,
  int b,
);

ffi.Pointer<ffi.Float> divide(
  int a,
  int b,
) {
  return _divide(
    a,
    b,
  );
}

final _dart_divide _divide =
    _dylib.lookupFunction<_c_divide, _dart_divide>('divide');

typedef _c_divide = ffi.Pointer<ffi.Float> Function(
  ffi.Int32 a,
  ffi.Int32 b,
);

typedef _dart_divide = ffi.Pointer<ffi.Float> Function(
  int a,
  int b,
);

ffi.Pointer<ffi.Double> dividePercision(
  ffi.Pointer<ffi.Float> a,
  ffi.Pointer<ffi.Float> b,
) {
  return _dividePercision(
    a,
    b,
  );
}

final _dart_dividePercision _dividePercision =
    _dylib.lookupFunction<_c_dividePercision, _dart_dividePercision>(
        'dividePercision');

typedef _c_dividePercision = ffi.Pointer<ffi.Double> Function(
  ffi.Pointer<ffi.Float> a,
  ffi.Pointer<ffi.Float> b,
);

typedef _dart_dividePercision = ffi.Pointer<ffi.Double> Function(
  ffi.Pointer<ffi.Float> a,
  ffi.Pointer<ffi.Float> b,
);