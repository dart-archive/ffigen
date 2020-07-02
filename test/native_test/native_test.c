// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#define aloc(T) ((T *)malloc(sizeof(T)))

#include <stdint.h>
#include <stdlib.h>

uint8_t Function1Uint8(uint8_t x) { return x + 42; }

uint16_t Function1Uint16(uint16_t x) { return x + 42; }

uint32_t Function1Uint32(uint32_t x) { return x + 42; }

uint64_t Function1Uint64(uint64_t x) { return x + 42; }

int8_t Function1Int8(int8_t x) { return x + 42; }

int16_t Function1Int16(int16_t x) { return x + 42; }

int32_t Function1Int32(int32_t x) { return x + 42; }

int64_t Function1Int64(int64_t x) { return x + 42; }

intptr_t Function1IntPtr(intptr_t x) { return x + 42; }

float Function1Float(float x) { return x + 42.0f; }

double Function1Double(double x) { return x + 42.0; }

struct Struct1
{
    int8_t a;
    int32_t data[3][1][2];
};

struct Struct1 *getStruct1()
{
    struct Struct1 *s = aloc(struct Struct1);
    s->a = 0;
    s->data[0][0][0] = 1;
    s->data[0][0][1] = 2;
    s->data[1][0][0] = 3;
    s->data[1][0][1] = 4;
    s->data[2][0][0] = 5;
    s->data[2][0][1] = 6;
    return s;
}
