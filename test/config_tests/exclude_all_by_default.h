// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void func();

struct Struct {
  int a;
};

union Union {
  int a;
};

int global;

#define MACRO 123

enum Enum {
  zero = 0,
};

enum {
  unnamedEnum = 123,
};
