// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct A {
  int a;
};

struct B {
  int B;
  int A;
};

struct C {
  struct A A;
  struct B B;
};

struct D {
  struct B A;
  struct A B;
};
