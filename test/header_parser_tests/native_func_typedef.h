// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct Struc
{
    void (*unnamed1)(void (*unnamed2)());
};

void func(void (*unnamed1)(void (*unnamed2)()));

// This will be removed because 'long double' is unsupported.
void funcNestedUnimplemented(void (*unnamed1)(void (*unnamed2)(long double)));

typedef void (*InsideReturnType)();
typedef InsideReturnType (*WithTypedefReturnType)();
void funcWithNativeFunc(WithTypedefReturnType named);

typedef void (*VoidFuncPointer)();
struct Struc2{
    const VoidFuncPointer constFuncPointer;
};
