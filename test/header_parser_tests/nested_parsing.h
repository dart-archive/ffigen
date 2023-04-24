// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct Struct2
{
    int e;
    int f;
};

struct Struct1
{
    int a;
    int b;
    struct Struct2 *struct2;
};

struct Struct3
{
    int a;
    // An unnamed struct.
    struct
    {
        int a;
        int b;
    } b;
};

struct EmptyStruct{
};

struct Struct4{
    int a;
    // Incomplete struct inside a struct.
    struct EmptyStruct b;
};

struct Struct5{
    int a;
    // Incomplete struct array.
    struct EmptyStruct b[3];
};

struct Struct6
{
    // An anonymous, unnamed union.
    union
    {
        float a;
    };

    // An unnamed union.
    union
    {
        float b;
    } c;

    union
    {
        float d;
    } e;
};
