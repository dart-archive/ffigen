// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

union Union1
{
    int a;
};

union Union2
{
    union Union1 a;
};

// Should be marked incomplete, long double not supported.
union Union3
{
    long double a;
};

// All members should be removed, Bit fields are not supported.
union Union4
{
    int a : 3;
    int : 2; // Unnamed bit field.
};

// All members should be removed, Incomplete union members are not supported.
union Union5
{
    int a;
    union Union3 s; // Incomplete nested union.
};

// Multiple anonymous declarations
union Union6
{
    union
    {
        float a;
    };

    union
    {
        float b;
    };
};

// Multiple anonymous declarations with incomplete members
union Union7
{
    union
    {
        float a;
    };

    union
    {
        float b;
        int c[];
    };
};

void func1(union Union2 *s);

// Incomplete array parameter will be treated as a pointer.
void func2(union Union3 s[]);
