// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Opaque.
struct A
{
    int a;
};

// Opaque.
struct B
{
    int a;
};

struct B *func(struct A *a);

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
