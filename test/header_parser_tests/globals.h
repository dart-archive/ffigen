// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdint.h>
#include <stdbool.h>

bool coolGlobal;
int32_t myInt;
int32_t *aGlobalPointer;
long double longDouble;
long double *pointerToLongDouble;

// This should be ignored
int GlobalIgnore;

struct EmptyStruct
{
};

struct EmptyStruct globalStruct;

typedef struct EmptyStruct EmptyStruct_Alias;
EmptyStruct_Alias globalStruct_from_alias;
