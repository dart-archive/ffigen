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
            returnType: Type.nativeType(
              SupportedNativeType.Int32,
            ),
          ),
          Func(
            name: 'withPrimitiveParam',
            parameters: [
              Parameter(
                name: 'a',
                type: Type.nativeType(
                  SupportedNativeType.Int32,
                ),
              ),
              Parameter(
                name: 'b',
                type: Type.nativeType(
                  SupportedNativeType.Uint8,
                ),
              ),
            ],
            returnType: Type.nativeType(
              SupportedNativeType.Char,
            ),
          ),
          Func(
            name: 'withPointerParam',
            parameters: [
              Parameter(
                name: 'a',
                type: Type.pointer(
                  Type.nativeType(
                    SupportedNativeType.Int32,
                  ),
                ),
              ),
              Parameter(
                name: 'b',
                type: Type.pointer(
                  Type.pointer(
                    Type.nativeType(
                      SupportedNativeType.Uint8,
                    ),
                  ),
                ),
              ),
            ],
            returnType: Type.pointer(
              Type.nativeType(
                SupportedNativeType.Double,
              ),
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
          Struc(
            name: 'NoMember',
            dartDoc: 'Just a test struct\nheres another line',
          ),
          Struc(
            name: 'WithPrimitiveMember',
            members: [
              Member(
                name: 'a',
                type: Type.nativeType(
                  SupportedNativeType.Int32,
                ),
              ),
              Member(
                name: 'b',
                type: Type.nativeType(
                  SupportedNativeType.Double,
                ),
              ),
              Member(
                name: 'c',
                type: Type.nativeType(
                  SupportedNativeType.Char,
                ),
              ),
            ],
          ),
          Struc(
            name: 'WithPointerMember',
            members: [
              Member(
                name: 'a',
                type: Type.pointer(
                  Type.nativeType(
                    SupportedNativeType.Int32,
                  ),
                ),
              ),
              Member(
                name: 'b',
                type: Type.pointer(
                  Type.pointer(
                    Type.nativeType(
                      SupportedNativeType.Double,
                    ),
                  ),
                ),
              ),
              Member(
                name: 'c',
                type: Type.nativeType(
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
      final struct_some = Struc(
        name: 'SomeStruc',
        members: [
          Member(
            name: 'a',
            type: Type.nativeType(
              SupportedNativeType.Int32,
            ),
          ),
          Member(
            name: 'b',
            type: Type.nativeType(
              SupportedNativeType.Double,
            ),
          ),
          Member(
            name: 'c',
            type: Type.nativeType(
              SupportedNativeType.Char,
            ),
          ),
        ],
      );
      final library = Library(
        name: 'Bindings',
        bindings: [
          struct_some,
          Func(
            name: 'someFunc',
            parameters: [
              Parameter(
                name: 'some',
                type: Type.pointer(
                  Type.pointer(
                    Type.struct(
                      struct_some,
                    ),
                  ),
                ),
              ),
            ],
            returnType: Type.pointer(
              Type.struct(
                struct_some,
              ),
            ),
          ),
        ],
      );

      _matchLib(library, 'function_n_struct');
    });

    test('global (primitives, pointers, pointer to struct)', () {
      final struc_some = Struc(
        name: 'Some',
      );
      final emptyGlobalStruc = Struc(name: 'EmptyStruct');

      final library = Library(
        name: 'Bindings',
        bindings: [
          Global(
            name: 'test1',
            type: Type.nativeType(
              SupportedNativeType.Int32,
            ),
          ),
          Global(
            name: 'test2',
            type: Type.pointer(
              Type.nativeType(
                SupportedNativeType.Float,
              ),
            ),
          ),
          struc_some,
          Global(
            name: 'test5',
            type: Type.pointer(
              Type.struct(
                struc_some,
              ),
            ),
          ),
          emptyGlobalStruc,
          Global(name: 'globalStruct', type: Type.struct(emptyGlobalStruc)),
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
        header: '// ignore_for_file: unused_element\n',
        bindings: [
          Func(
            name: 'test',
            returnType: Type.nativeType(SupportedNativeType.Void),
          ),
          Func(
            name: '_test',
            returnType: Type.nativeType(SupportedNativeType.Void),
          ),
          Func(
            name: '_c_test',
            returnType: Type.nativeType(SupportedNativeType.Void),
          ),
          Func(
            name: '_dart_test',
            returnType: Type.nativeType(SupportedNativeType.Void),
          ),
          Struc(
            name: '_Test',
            members: [
              Member(
                name: 'array',
                type: Type.constantArray(
                  2,
                  Type.nativeType(
                    SupportedNativeType.Int8,
                  ),
                ),
              ),
            ],
          ),
          Struc(name: 'ArrayHelperPrefixCollisionTest'),
          Func(
            name: 'Test',
            returnType: Type.nativeType(SupportedNativeType.Void),
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
      dartBool: true,
      bindings: [
        Func(
          name: 'test1',
          returnType: Type.boolean(),
          parameters: [
            Parameter(name: 'a', type: Type.boolean()),
            Parameter(name: 'b', type: Type.pointer(Type.boolean())),
          ],
        ),
        Struc(
          name: 'test2',
          members: [
            Member(name: 'a', type: Type.boolean()),
          ],
        ),
      ],
    );
    _matchLib(library, 'boolean_dartbool');
  });
  test('boolean_no_dartBool', () {
    final library = Library(
      name: 'Bindings',
      dartBool: false,
      bindings: [
        Func(
          name: 'test1',
          returnType: Type.boolean(),
          parameters: [
            Parameter(name: 'a', type: Type.boolean()),
            Parameter(name: 'b', type: Type.pointer(Type.boolean())),
          ],
        ),
        Struc(
          name: 'test2',
          members: [
            Member(name: 'a', type: Type.boolean()),
          ],
        ),
      ],
    );
    _matchLib(library, 'boolean_no_dartbool');
  });
  test('sort bindings', () {
    final library = Library(
      name: 'Bindings',
      sort: true,
      bindings: [
        Func(name: 'b', returnType: Type.nativeType(SupportedNativeType.Void)),
        Func(name: 'a', returnType: Type.nativeType(SupportedNativeType.Void)),
        Struc(name: 'd'),
        Struc(name: 'c'),
      ],
    );
    _matchLib(library, 'sort_bindings');
  });
  test('Pack Structs', () {
    final library = Library(
      name: 'Bindings',
      bindings: [
        Struc(name: 'NoPacking', pack: null, members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Char)),
        ]),
        Struc(name: 'Pack1', pack: 1, members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Char)),
        ]),
        Struc(name: 'Pack2', pack: 2, members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Char)),
        ]),
        Struc(name: 'Pack2', pack: 4, members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Char)),
        ]),
        Struc(name: 'Pack2', pack: 8, members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Char)),
        ]),
        Struc(name: 'Pack16', pack: 16, members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Char)),
        ]),
      ],
    );
    _matchLib(library, 'packed_structs');
  });
  test('Union Bindings', () {
    final struct1 = Struc(name: 'Struct1', members: [
      Member(name: 'a', type: Type.nativeType(SupportedNativeType.Int8))
    ]);
    final union1 = Union(name: 'Union1', members: [
      Member(name: 'a', type: Type.nativeType(SupportedNativeType.Int8))
    ]);
    final library = Library(
      name: 'Bindings',
      bindings: [
        struct1,
        union1,
        Union(name: 'EmptyUnion'),
        Union(name: 'Primitives', members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Int8)),
          Member(name: 'b', type: Type.nativeType(SupportedNativeType.Int32)),
          Member(name: 'c', type: Type.nativeType(SupportedNativeType.Float)),
          Member(name: 'd', type: Type.nativeType(SupportedNativeType.Double)),
        ]),
        Union(name: 'PrimitivesWithPointers', members: [
          Member(name: 'a', type: Type.nativeType(SupportedNativeType.Int8)),
          Member(name: 'b', type: Type.nativeType(SupportedNativeType.Float)),
          Member(
              name: 'c',
              type: Type.pointer(Type.nativeType(SupportedNativeType.Double))),
          Member(name: 'd', type: Type.pointer(Type.union(union1))),
          Member(name: 'd', type: Type.pointer(Type.struct(struct1))),
        ]),
        Union(name: 'WithArray', members: [
          Member(
              name: 'a',
              type: Type.constantArray(
                  10, Type.nativeType(SupportedNativeType.Int8))),
          Member(name: 'b', type: Type.constantArray(10, Type.union(union1))),
          Member(name: 'b', type: Type.constantArray(10, Type.struct(struct1))),
          Member(
              name: 'c',
              type: Type.constantArray(10, Type.pointer(Type.union(union1)))),
        ]),
      ],
    );
    _matchLib(library, 'unions');
  });
}

/// Utility to match expected bindings to the generated bindings.
void _matchLib(Library lib, String testName) {
  matchLibraryWithExpected(lib, [
    'test',
    'debug_generated',
    'code_generator_test_${testName}_output.dart'
  ], [
    'test',
    'code_generator_tests',
    'expected_bindings',
    '_expected_${testName}_bindings.dart'
  ]);
}
