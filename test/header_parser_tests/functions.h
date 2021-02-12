// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdint.h>

// Simple tests with primitives.
void func1();
int32_t func2(int16_t);
double func3(float, int8_t a, int64_t, int32_t b);

// Tests with pointers to primitives.
void *func4(int8_t **, double, int32_t ***);

// Would be treated as `typedef void shortHand(void (*b)())`.
typedef void shortHand(void(b)());
// Would be treated as `void func5(shortHand *a, void (*b)())`.
void func5(shortHand a, void(b)());

// Should be skipped as inline functions are not supported.
static inline void inlineFunc();
