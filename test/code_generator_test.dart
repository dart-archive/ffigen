import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for code_generator(ffi_tool)', () {
    test('Function Binding', () {
      final library = Library(
        bindings: [
          Func(
            name: 'test',
            dartDoc: 'Just a test function\nheres another line',
            returnType: Type('int32'),
          ),
          Func(
            name: 'anotherTest',
            parameters: [
              Parameter(name: 'a', type: Type('int32')),
              Parameter(name: 'b', type: Type('uint8')),
            ],
            returnType: Type('char'),
          ),
          Func(
            name: 'last',
            returnType: Type('float64'),
          ),
        ],
      );

      var gen = library.toString();

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
int test(
) {
  return _test(
  );
}

final _dart_test _test = _dylib.lookupFunction<_c_test,_dart_test>('test');

typedef _c_test = ffi.Int32 Function(
);

typedef _dart_test = int Function(
);

int anotherTest(
  int a,
  int b,
) {
  return _anotherTest(
    a,
    b,
  );
}

final _dart_anotherTest _anotherTest = _dylib.lookupFunction<_c_anotherTest,_dart_anotherTest>('anotherTest');

typedef _c_anotherTest = ffi.Uint8 Function(
  ffi.Int32 a,
  ffi.Uint8 b,
);

typedef _dart_anotherTest = int Function(
  int a,
  int b,
);

double last(
) {
  return _last(
  );
}

final _dart_last _last = _dylib.lookupFunction<_c_last,_dart_last>('last');

typedef _c_last = ffi.Double Function(
);

typedef _dart_last = double Function(
);

''');
      // writing to file for debug purpose
      File(
        'test/debug_generated/Function-Binding-test-output.dart',
      )..writeAsStringSync(gen);
    });

    test('Struct Binding', () {
      final library = Library(
        bindings: [
          Struc(
            name: 'test',
            dartDoc: 'Just a test function\nheres another line',
          ),
          Struc(
            name: 'anotherTest',
            members: [
              Member(name: 'a', type: Type('int32')),
              Member(name: 'b', type: Type('double')),
              Member(name: 'c', type: Type('char')),
            ],
          ),
        ],
      );

      var gen = library.toString();

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
class test extends ffi.Struct{
}

class anotherTest extends ffi.Struct{
  @ffi.Int32()
  int a;

  @ffi.Double()
  double b;

  @ffi.Uint8()
  int c;

}

''');

      // writing to file for debug purpose
      File('test/debug_generated/Struct-Binding-test-output.dart')
        ..writeAsStringSync(gen);
    });
  });
}
