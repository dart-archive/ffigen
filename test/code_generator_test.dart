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

      library.generateFile(
        File('test/debug_generated/Function-Binding-test-output.dart'),
      );

      //TODO: complete test
    });
  });
}
