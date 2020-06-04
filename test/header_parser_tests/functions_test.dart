import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/config_provider.dart';
import 'package:test/test.dart';

void main() {
  group('header_parser', () {
    test('functions', () {
      Config config = Config(
        compilerOpts:
            '-I/usr/lib/llvm-9/include/ -I/usr/lib/llvm-10/include/'.split(' '),
        libclang_dylib_path: 'tool/wrapped_libclang/libwrapped_clang.so',
        headers: [
          Header('test/header_parser_tests/functions.h'),
        ],
        includedInclusionHeaders: {
          'functions.h',
        },
      );
      Library testLib = parser.parse(config, sort: true);
      var file = File('test/debug_generated/header_parser_function.dart');
      try {
        expect(testLib.toString(), functionLibrary().toString());
        if (file.existsSync()) {
          file.delete();
        }
      } catch (e) {
        testLib.generateFile(file);
        print("Failed test, Debug output: ${file.absolute?.path}");
        rethrow;
      }
    });
  });
}

Library functionLibrary() {
  return Library(
    bindings: [
      Func(
        name: 'test1',
        returnType: Type.nativeType(
          nativeType: SupportedNativeType.Void,
        ),
      ),
      Func(
        name: 'test2',
        returnType: Type.nativeType(
          nativeType: SupportedNativeType.Int32,
        ),
        parameters: [
          Parameter(
            name: '',
            type: Type.nativeType(
              nativeType: SupportedNativeType.Int16,
            ),
          ),
        ],
      ),
      Func(
        name: 'test3',
        returnType: Type.nativeType(
          nativeType: SupportedNativeType.Double,
        ),
        parameters: [
          Parameter(
            type: Type.nativeType(
              nativeType: SupportedNativeType.Float,
            ),
          ),
          Parameter(
            name: 'a',
            type: Type.nativeType(
              nativeType: SupportedNativeType.Int8,
            ),
          ),
          Parameter(
            name: '',
            type: Type.nativeType(
              nativeType: SupportedNativeType.Int64,
            ),
          ),
          Parameter(
            name: 'b',
            type: Type.nativeType(
              nativeType: SupportedNativeType.Int32,
            ),
          ),
        ],
      ),
    ],
  )..sort();
}
