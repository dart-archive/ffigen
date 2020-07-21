// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#define Macro1 1
#define Test_Macro2 2

struct Struct1
{
};
struct Test_Struct2
{
};

void func1(struct Struct1 *s);
void test_func2(struct Test_Struct2 *s);

enum Enum1
{
    a = 0,
    b = 1,
    c = 2
};
enum Test_Enum2
{
    e = 0,
    f = 1,
    g = 2
};
