// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <dart_api.h>

void func1(Dart_Handle);
Dart_Handle func2();
Dart_Handle **func3(Dart_Handle *);

typedef void (*Typedef1)(Dart_Handle);
void func4(Typedef1);

// Dart_Handle isn't supported directly, so all members are removed.
struct Struct1
{
    Dart_Handle h;
    int a;
};

// Pointer<Handle> works.
struct Struct2
{
    Dart_Handle *h;
};
