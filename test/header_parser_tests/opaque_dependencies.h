// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Opaque.
struct A
{
    int a;
};

// Opaque.
typedef struct B
{
    int a;
} BAlias;

BAlias *func(struct A *a);

// Opaque.
struct C
{
    int a;
};

// Full (excluded, but used by value).
struct D
{
    int a;
};

// Full (included)
struct E
{
    struct C *c;
    struct D d;
};

// Opaque.
union UA
{
    int a;
};

// Opaque.
union UB
{
    int a;
};

union UB *func2(union UA *a);

// Opaque.
union UC
{
    int a;
};

// Full (excluded, but used by value).
union UD
{
    int a;
};

// Full (included)
union UE
{
    union UC *c;
    union UD d;
};
