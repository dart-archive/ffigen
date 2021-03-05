// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct A;
enum B;

void func(struct A *a, enum B b);

struct A
{
    int a;
    int b;
};

enum B
{
    a,
    b
};
