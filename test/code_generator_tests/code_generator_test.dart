// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('code_generator: ', () {
    test('Function Binding (primitives, pointers)', () {
      final library = Library(
        name: 'Bindings',
        bindings: [
          Func(
            name: 'noParam',
            dartDoc: 'Just a test function\nheres another line',
            returnType: NativeType(
              SupportedNativeType.Int32,
            ),
          ),
          Func(
            name: 'withPrimitiveParam',
            parameters: [
              Parameter(
                name: 'a',
                type: NativeType(
                  SupportedNativeType.Int32,
                ),
              ),
              Parameter(
                name: 'b',
                type: NativeType(
                  SupportedNativeType.Uint8,
                ),
              ),
            ],
            returnType: NativeType(
              SupportedNativeType.Char,
            ),
          ),
          Func(
            name: 'withPointerParam',
            parameters: [
              Parameter(
                name: 'a',
                type: PointerType(
                  NativeType(
                    SupportedNativeType.Int32,
                  ),
                ),
              ),
              Parameter(
                name: 'b',
                type: PointerType(
                  PointerType(
                    NativeType(
                      SupportedNativeType.Uint8,
                    ),
                  ),
                ),
              ),
            ],
            returnType: PointerType(
              NativeType(
                SupportedNativeType.Double,
              ),
            ),
          ),
          Func(
            isLeaf: true,
            name: 'leafFunc',
            dartDoc: 'A function with isLeaf: true',
            parameters: [
              Parameter(
                name: 'a',
                type: NativeType(
                  SupportedNativeType.Int32,
                ),
              ),
            ],
            returnType: NativeType(
              SupportedNativeType.Int32,
            ),
          ),
        ],
      );

      _matchLib(library, 'function');
    });

    test('Struct Binding (primitives, pointers)', () {
      final library = Library(
        name: 'Bindings',
        bindings: [
          Struct(
            name: 'NoMember',
            dartDoc: 'Just a test struct\nheres another line',
          ),
          Struct(
            name: 'WithPrimitiveMember',
            members: [
              Member(
                name: 'a',
                type: NativeType(
                  SupportedNativeType.Int32,
                ),
              ),
              Member(
                name: 'b',
                type: NativeType(
                  SupportedNativeType.Double,
                ),
              ),
              Member(
                name: 'c',
                type: NativeType(
                  SupportedNativeType.Char,
                ),
              ),
            ],
          ),
          Struct(
            name: 'WithPointerMember',
            members: [
              Member(
                name: 'a',
                type: PointerType(
                  NativeType(
                    SupportedNativeType.Int32,
                  ),
                ),
              ),
              Member(
                name: 'b',
                type: PointerType(
                  PointerType(
                    NativeType(
                      SupportedNativeType.Double,
                    ),
                  ),
                ),
              ),
              Member(
                name: 'c',
                type: NativeType(
                  SupportedNativeType.Char,
                ),
              ),
            ],
          ),
        ],
      );

      _matchLib(library, 'struct');
    });

    test('Function and Struct Binding (pointer to Struct)', () {
      final structSome = Struct(
        name: 'SomeStruct',
        members: [
          Member(
            name: 'a',
            type: NativeType(
              SupportedNativeType.Int32,
            ),
          ),
          Member(
            name: 'b',
            type: NativeType(
              SupportedNativeType.Double,
            ),
          ),
          Member(
            name: 'c',
            type: NativeType(
              SupportedNativeType.Char,
            ),
          ),
        ],
      );
      final library = Library(
        name: 'Bindings',
        bindings: [
          structSome,
          Func(
            name: 'someFunc',
            parameters: [
              Parameter(
                name: 'some',
                type: PointerType(
                  PointerType(
                    structSome,
                  ),
                ),
              ),
            ],
            returnType: PointerType(
              structSome,
            ),
          ),
        ],
      );

      _matchLib(library, 'function_n_struct');
    });

    test('global (primitives, pointers, pointer to struct)', () {
      final structSome = Struct(
        name: 'Some',
      );
      final emptyGlobalStruct = Struct(name: 'EmptyStruct');

      final library = Library(
        name: 'Bindings',
        bindings: [
          Global(
            name: 'test1',
            type: NativeType(
              SupportedNativeType.Int32,
            ),
          ),
          Global(
            name: 'test2',
            type: PointerType(
              NativeType(
                SupportedNativeType.Float,
              ),
            ),
          ),
          structSome,
          Global(
            name: 'test5',
            type: PointerType(
              structSome,
            ),
          ),
          emptyGlobalStruct,
          Global(name: 'globalStruct', type: emptyGlobalStruct),
        ],
      );
      _matchLib(library, 'global');
    });

    test('constant', () {
      final library = Library(
        name: 'Bindings',
        header: '// ignore_for_file: unused_import\n',
        bindings: [
          Constant(
            name: 'test1',
            rawType: 'int',
            rawValue: '20',
          ),
          Constant(
            name: 'test2',
            rawType: 'double',
            rawValue: '20.0',
          ),
        ],
      );
      _matchLib(library, 'constant');
    });

    test('enum_class', () {
      final library = Library(
        name: 'Bindings',
        header: '// ignore_for_file: unused_import\n',
        bindings: [
          EnumClass(
            name: 'Constants',
            dartDoc: 'test line 1\ntest line 2',
            enumConstants: [
              EnumConstant(
                name: 'a',
                value: 10,
              ),
              EnumConstant(name: 'b', value: -1, dartDoc: 'negative'),
            ],
          ),
        ],
      );
      _matchLib(library, 'enumclass');
    });
    test('Internal conflict resolution', () {
      final library = Library(
        name: 'init_dylib',
        header:
            '// ignore_for_file: unused_element, camel_case_types, non_constant_identifier_names\n',
        bindings: [
          Func(
            name: 'test',
            returnType: NativeType(SupportedNativeType.Void),
          ),
          Func(
            name: '_test',
            returnType: NativeType(SupportedNativeType.Void),
          ),
          Func(
            name: '_c_test',
            returnType: NativeType(SupportedNativeType.Void),
          ),
          Func(
            name: '_dart_test',
            returnType: NativeType(SupportedNativeType.Void),
          ),
          Struct(
            name: '_Test',
            members: [
              Member(
                name: 'array',
                type: ConstantArray(
                  2,
                  NativeType(
                    SupportedNativeType.Int8,
                  ),
                ),
              ),
            ],
          ),
          Struct(name: 'ArrayHelperPrefixCollisionTest'),
          Func(
            name: 'Test',
            returnType: NativeType(SupportedNativeType.Void),
          ),
          EnumClass(name: '_c_Test'),
          EnumClass(name: 'init_dylib'),
        ],
      );
      _matchLib(library, 'internal_conflict_resolution');
    });
  });
  test('boolean_dartBool', () {
    final library = Library(
      name: 'Bindings',
      bindings: [
        Func(
          name: 'test1',
          returnType: BooleanType(),
          parameters: [
            Parameter(name: 'a', type: BooleanType()),
            Parameter(name: 'b', type: PointerType(BooleanType())),
          ],
        ),
        Struct(
          name: 'Test2',
          members: [
            Member(name: 'a', type: BooleanType()),
          ],
        ),
      ],
    );
    _matchLib(library, 'boolean_dartbool');
  });
  test('sort bindings', () {
    final library = Library(
      name: 'Bindings',
      sort: true,
      bindings: [
        Func(name: 'b', returnType: NativeType(SupportedNativeType.Void)),
        Func(name: 'a', returnType: NativeType(SupportedNativeType.Void)),
        Struct(name: 'D'),
        Struct(name: 'C'),
      ],
    );
    _matchLib(library, 'sort_bindings');
  });
  test('Pack Structs', () {
    final library = Library(
      name: 'Bindings',
      bindings: [
        Struct(name: 'NoPacking', pack: null, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.Char)),
        ]),
        Struct(name: 'Pack1', pack: 1, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.Char)),
        ]),
        Struct(name: 'Pack2', pack: 2, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.Char)),
        ]),
        Struct(name: 'Pack2', pack: 4, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.Char)),
        ]),
        Struct(name: 'Pack2', pack: 8, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.Char)),
        ]),
        Struct(name: 'Pack16', pack: 16, members: [
          Member(name: 'a', type: NativeType(SupportedNativeType.Char)),
        ]),
      ],
    );
    _matchLib(library, 'packed_structs');
  });
  test('Union Bindings', () {
    final struct1 =
        Struct(name: 'Struct1', members: [Member(name: 'a', type: charType)]);
    final union1 =
        Union(name: 'Union1', members: [Member(name: 'a', type: charType)]);
    final library = Library(
      name: 'Bindings',
      bindings: [
        struct1,
        union1,
        Union(name: 'EmptyUnion'),
        Union(name: 'Primitives', members: [
          Member(name: 'a', type: charType),
          Member(name: 'b', type: intType),
          Member(name: 'c', type: floatType),
          Member(name: 'd', type: doubleType),
        ]),
        Union(name: 'PrimitivesWithPointers', members: [
          Member(name: 'a', type: charType),
          Member(name: 'b', type: floatType),
          Member(name: 'c', type: PointerType(doubleType)),
          Member(name: 'd', type: PointerType(union1)),
          Member(name: 'd', type: PointerType(struct1)),
        ]),
        Union(name: 'WithArray', members: [
          Member(name: 'a', type: ConstantArray(10, charType)),
          Member(name: 'b', type: ConstantArray(10, union1)),
          Member(name: 'b', type: ConstantArray(10, struct1)),
          Member(name: 'c', type: ConstantArray(10, PointerType(union1))),
        ]),
      ],
    );
    _matchLib(library, 'unions');
  });
  test('Typealias Bindings', () {
    final library = Library(
      name: 'Bindings',
      header: '// ignore_for_file: non_constant_identifier_names\n',
      bindings: [
        Typealias(name: 'RawUnused', type: Struct(name: 'Struct1')),
        Struct(name: 'WithTypealiasStruct', members: [
          Member(
              name: 't',
              type: Typealias(
                  name: 'Struct2Typealias',
                  type: Struct(
                      name: 'Struct2',
                      members: [Member(name: 'a', type: doubleType)])))
        ]),
        Func(
            name: 'WithTypealiasStruct',
            returnType: PointerType(NativeFunc(FunctionType(
                returnType: NativeType(SupportedNativeType.Void),
                parameters: []))),
            parameters: [
              Parameter(
                  name: 't',
                  type: Typealias(
                      name: 'Struct3Typealias', type: Struct(name: 'Struct3')))
            ]),
      ],
    );
    _matchLib(library, 'typealias');
  });
}

/// Utility to match expected bindings to the generated bindings.
void _matchLib(Library lib, String testName) {
  matchLibraryWithExpected(lib, 'code_generator_test_${testName}_output.dart', [
    'test',
    'code_generator_tests',
    'expected_bindings',
    '_expected_${testName}_bindings.dart'
  ]);
}
