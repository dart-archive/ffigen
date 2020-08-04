// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#define Macro1 1
#define Test_Macro2 2
#define FullMatchMacro3 3

struct Struct1
{
};
struct Test_Struct2
{
};
struct FullMatchStruct3
{
};
struct MemberRenameStruct4
{
    int _underscore;
    float fullMatch;
};

struct AnyMatchStruct5
{
    int _underscore;
};

void func1(struct Struct1 *s);
void test_func2(struct Test_Struct2 *s);
void fullMatch_func3(struct FullMatchStruct3 *s);
void memberRename_func4(int _underscore, float fullMatch, int);

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
enum FullMatchEnum3
{
    i = 0,
    j = 1,
    k = 2
};
enum MemberRenameEnum4
{
    _underscore = 0,
    fullMatch = 1
};
enum
{
    _unnamed_underscore = 0,
    unnamedFullMatch = 1
};
