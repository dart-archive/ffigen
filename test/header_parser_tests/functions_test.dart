import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/writer.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/config_provider.dart';
import 'package:test/test.dart';

final writer = Writer();

void main() {
  group('header_parser', () {
    Library actual, expected;

    setUpAll(() {
      expected = expectedLibrary();
      actual = parser.parse(
        Config(
          compilerOpts: '-I/usr/lib/llvm-9/include/ -I/usr/lib/llvm-10/include/'
              .split(' '),
          libclang_dylib_path: 'tool/wrapped_libclang/libwrapped_clang.so',
          headers: [
            Header('test/header_parser_tests/functions.h'),
          ],
          headerFilter: HeaderFilter(
            includedInclusionHeaders: {
              'functions.h',
            },
          ),
        ),
      );
    });
    test('Total bindings count', () {
      expect(actual.bindings.length, expected.bindings.length);
    });

    test('func1', () {
      expect(binding(actual, 'func1'), binding(expected, 'func1'));
    });
    test('func2', () {
      expect(binding(actual, 'func2'), binding(expected, 'func2'));
    });
    test('func3', () {
      expect(binding(actual, 'func3'), binding(expected, 'func3'));
    });

    test('func4', () {
      expect(binding(actual, 'func4'), binding(expected, 'func4'));
    });
  });
}

/// Extracts a binding's string from a library
String binding(Library lib, String name) {
  return lib.bindings
      .firstWhere((element) => element.name == name)
      .toBindingString(writer)
      .string;
}

Library expectedLibrary() {
  return Library(
    bindings: [
      Func(
        name: 'func1',
        returnType: Type.nativeType(
          SupportedNativeType.Void,
        ),
      ),
      Func(
        name: 'func2',
        returnType: Type.nativeType(
          SupportedNativeType.Int32,
        ),
        parameters: [
          Parameter(
            name: '',
            type: Type.nativeType(
              SupportedNativeType.Int16,
            ),
          ),
        ],
      ),
      Func(
        name: 'func3',
        returnType: Type.nativeType(
          SupportedNativeType.Double,
        ),
        parameters: [
          Parameter(
            type: Type.nativeType(
              SupportedNativeType.Float,
            ),
          ),
          Parameter(
            name: 'a',
            type: Type.nativeType(
              SupportedNativeType.Int8,
            ),
          ),
          Parameter(
            name: '',
            type: Type.nativeType(
              SupportedNativeType.Int64,
            ),
          ),
          Parameter(
            name: 'b',
            type: Type.nativeType(
              SupportedNativeType.Int32,
            ),
          ),
        ],
      ),
      Func(
          name: 'func4',
          returnType: Type.pointer(Type.nativeType(SupportedNativeType.Void)),
          parameters: [
            Parameter(
                type: Type.pointer(
                    Type.pointer(Type.nativeType(SupportedNativeType.Int8)))),
            Parameter(type: Type.nativeType(SupportedNativeType.Double)),
            Parameter(
              type: Type.pointer(Type.pointer(
                  Type.pointer(Type.nativeType(SupportedNativeType.Int32)))),
            )
          ]),
    ],
  );
}
