import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('code_generator: ', () {
    test('Function Binding (primitives, pointers)', () {
      final library = Library(
        bindings: [
          Func(
            name: 'noParam',
            dartDoc: 'Just a test function\nheres another line',
            returnType: Type('int32'),
          ),
          Func(
            name: 'withPrimitiveParam',
            parameters: [
              Parameter(name: 'a', type: Type('int32')),
              Parameter(name: 'b', type: Type('uint8')),
            ],
            returnType: Type('char'),
          ),
          Func(
            name: 'withPointerParam',
            parameters: [
              Parameter(name: 'a', type: Type('*int32')),
              Parameter(name: 'b', type: Type('**uint8')),
            ],
            returnType: Type('*float64'),
          ),
        ],
      );

      var gen = library.toString();

      // writing to file for debug purpose
      File(
        'test/debug_generated/Function-Binding-test-output.dart',
      )..writeAsStringSync(gen);

      expect(gen, '''/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib){
  _dylib = dylib;
}
/// Just a test function
/// heres another line
int noParam(
) {
  return _noParam(
  );
}

final _dart_noParam _noParam = _dylib.lookupFunction<_c_noParam,_dart_noParam>('noParam');

typedef _c_noParam = ffi.Int32 Function(
);

typedef _dart_noParam = int Function(
);

int withPrimitiveParam(
  int a,
  int b,
) {
  return _withPrimitiveParam(
    a,
    b,
  );
}

final _dart_withPrimitiveParam _withPrimitiveParam = _dylib.lookupFunction<_c_withPrimitiveParam,_dart_withPrimitiveParam>('withPrimitiveParam');

typedef _c_withPrimitiveParam = ffi.Uint8 Function(
  ffi.Int32 a,
  ffi.Uint8 b,
);

typedef _dart_withPrimitiveParam = int Function(
  int a,
  int b,
);

ffi.Pointer<ffi.Double> withPointerParam(
  ffi.Pointer<ffi.Int32> a,
  ffi.Pointer<ffi.Pointer<ffi.Uint8>> b,
) {
  return _withPointerParam(
    a,
    b,
  );
}

final _dart_withPointerParam _withPointerParam = _dylib.lookupFunction<_c_withPointerParam,_dart_withPointerParam>('withPointerParam');

typedef _c_withPointerParam = ffi.Pointer<ffi.Double> Function(
  ffi.Pointer<ffi.Int32> a,
  ffi.Pointer<ffi.Pointer<ffi.Uint8>> b,
);

typedef _dart_withPointerParam = ffi.Pointer<ffi.Double> Function(
  ffi.Pointer<ffi.Int32> a,
  ffi.Pointer<ffi.Pointer<ffi.Uint8>> b,
);

''');
    });

    test('Struct Binding (primitives, pointers)', () {
      final library = Library(
        bindings: [
          Struc(
            name: 'NoMember',
            dartDoc: 'Just a test struct\nheres another line',
          ),
          Struc(
            name: 'WithPrimitiveMember',
            members: [
              Member(name: 'a', type: Type('int32')),
              Member(name: 'b', type: Type('double')),
              Member(name: 'c', type: Type('char')),
            ],
          ),
          Struc(
            name: 'WithPointerMember',
            members: [
              Member(name: 'a', type: Type('*int32')),
              Member(name: 'b', type: Type('**double')),
              Member(name: 'c', type: Type('char')),
            ],
          ),
        ],
      );

      var gen = library.toString();

      // writing to file for debug purpose
      File('test/debug_generated/Struct-Binding-test-output.dart')
        ..writeAsStringSync(gen);

      expect(gen, '''/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib){
  _dylib = dylib;
}
/// Just a test struct
/// heres another line
class NoMember extends ffi.Struct{
}

class WithPrimitiveMember extends ffi.Struct{
  @ffi.Int32()
  int a;

  @ffi.Double()
  double b;

  @ffi.Uint8()
  int c;

}

class WithPointerMember extends ffi.Struct{
  ffi.Pointer<ffi.Int32> a;

  ffi.Pointer<ffi.Pointer<ffi.Double>> b;

  @ffi.Uint8()
  int c;

}

''');
    });
    test('Function and Struct Binding (pointer to Struct)', () {
      final library = Library(
        bindings: [
          Struc(
            name: 'SomeStruc',
            members: [
              Member(name: 'a', type: Type('int32')),
              Member(name: 'b', type: Type('double')),
              Member(name: 'c', type: Type('char')),
            ],
          ),
          Func(
            name: 'someFunc',
            parameters: [
              Parameter(name: 'some', type: Type('**SomeStruc')),
            ],
            returnType: Type(
              '*SomeStruc',
            ),
          ),
        ],
      );

      var gen = library.toString();

      // writing to file for debug purpose
      File('test/debug_generated/Func-n-Struct-Binding-test-output.dart')
        ..writeAsStringSync(gen);

      expect(gen, '''/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib){
  _dylib = dylib;
}
class SomeStruc extends ffi.Struct{
  @ffi.Int32()
  int a;

  @ffi.Double()
  double b;

  @ffi.Uint8()
  int c;

}

ffi.Pointer<SomeStruc> someFunc(
  ffi.Pointer<ffi.Pointer<SomeStruc>> some,
) {
  return _someFunc(
    some,
  );
}

final _dart_someFunc _someFunc = _dylib.lookupFunction<_c_someFunc,_dart_someFunc>('someFunc');

typedef _c_someFunc = ffi.Pointer<SomeStruc> Function(
  ffi.Pointer<ffi.Pointer<SomeStruc>> some,
);

typedef _dart_someFunc = ffi.Pointer<SomeStruc> Function(
  ffi.Pointer<ffi.Pointer<SomeStruc>> some,
);

''');
    });

    test('global (primitives, pointers, pointer to struct, pointer to ffiUtil)',
        () {
      final library = Library(
        bindings: [
          Global(
            name: 'test1',
            type: Type('int32'),
          ),
          Global(
            name: 'test2',
            type: Type('*float'),
          ),
          Global(
            name: 'test3',
            type: Type('*utf8'),
          ),
          Global(
            name: 'test4',
            type: Type('*utf16'),
          ),
          Struc(
            name: 'Some',
          ),
          Global(
            name: 'test5',
            type: Type('*Some'),
          ),
        ],
      );

      var gen = library.toString();

      // writing to file for debug purpose
      File(
        'test/debug_generated/Global-Binding-test-output.dart',
      )..writeAsStringSync(gen);

      expect(gen, '''/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib){
  _dylib = dylib;
}
final int test1 = _dylib.lookup<ffi.Int32>('test1').value;

final ffi.Pointer<ffi.Float> test2 = _dylib.lookup<ffi.Pointer<ffi.Float>>('test2').value;

final ffi.Pointer<ffi2.Utf8> test3 = _dylib.lookup<ffi.Pointer<ffi2.Utf8>>('test3').value;

final ffi.Pointer<ffi2.Utf16> test4 = _dylib.lookup<ffi.Pointer<ffi2.Utf16>>('test4').value;

class Some extends ffi.Struct{
}

final ffi.Pointer<Some> test5 = _dylib.lookup<ffi.Pointer<Some>>('test5').value;

''');
    });

    test('constant',
        () {
      final library = Library(
        bindings: [
          Constant(
            name: 'test1',
            type: Type('int32'),
            rawValue: '20',
          ),
          Constant(
            name: 'test2',
            type: Type('float'),
            rawValue: '20.0',
          ),
        ],
      );

      var gen = library.toString();

      // writing to file for debug purpose
      File(
        'test/debug_generated/Constant-test-output.dart',
      )..writeAsStringSync(gen);

      expect(gen, '''/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib){
  _dylib = dylib;
}
const int test1 = 20;

const double test2 = 20.0;

''');
    });
  });
}
