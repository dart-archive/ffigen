// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct Struct1
{
    int a;
};

struct Struct2
{
    struct Struct1 a;
};

// All members should be removed, Flexible array members are not supported.
struct Struct3
{
    int a;
    int b[]; // Flexible array member.
};

// All members should be removed, Bit fields are not supported.
struct Struct4
{
    int a : 3;
    int : 2; // Unnamed bit field.
};

// All members should be removed, Incomplete struct members are not supported.
struct Struct5
{
    int a;
    struct Struct3 s; // Incomplete nested struct.
};

typedef int arr10[10];

struct Struct6
{
    arr10 a[2];
};

void func1(struct Struct2 *s);

// Incomplete array parameter will be treated as a pointer.
void func2(struct Struct3 s[]);

void func3(arr10 a);
