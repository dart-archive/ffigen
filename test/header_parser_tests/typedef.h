// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

typedef void (*NamedFunctionProto)();

struct Struct1
{
    NamedFunctionProto named;
    void (*unnamed)();
};

extern NamedFunctionProto func1(NamedFunctionProto named, void (*unnamed)(int));

typedef struct
{

} AnonymousStructInTypedef;
// These typerefs do not affect the name of AnonymousStructInTypedef.
typedef AnonymousStructInTypedef Typeref1;
typedef AnonymousStructInTypedef Typeref2;

// Name from global namespace is used.
typedef struct _NamedStructInTypedef
{

} NamedStructInTypedef;

// Both these names must be exlucded or this struct will be generated.
typedef struct _ExcludedStruct
{

} ExcludedStruct;
typedef ExcludedStruct NTyperef1;

// Because `struct _ExcludedStruct` is excluded, the type name used
// in this function (the first function) will be used.
// Therefore, _ExcludedStruct will be generated as NTyperef1.
void func2(NTyperef1 *);

typedef enum
{
    a = 0
} AnonymousEnumInTypedef;

// Name from global namespace is used.
typedef enum _NamedEnumInTypedef
{
    b = 0
} NamedEnumInTypedef;

// Should be treated as IntPtr when used.
typedef char specified_type_as_IntPtr;
typedef specified_type_as_IntPtr nesting_a_specified_type;

void func3(specified_type_as_IntPtr, nesting_a_specified_type b);

// Struct3 is used. `pStruct2` and `pStruct3` are ignored.
typedef struct
{
} Struct2, Struct3, *pStruct2, *pStruct3;
