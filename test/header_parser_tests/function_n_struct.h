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

struct Struct3
{
    int a;
    int b[]; // Flexible array member.
};

void func1(struct Struct2 *s);

// Incomplete array parameter will be treated as a pointer.
void func2(struct Struct3 s[]);
