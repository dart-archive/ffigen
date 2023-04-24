// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct BaseStruct1{
    int a;
};

union BaseUnion1{
    int a;
};

struct BaseStruct2{
    int a;
};

union BaseUnion2{
    int a;
};

typedef struct BaseStruct1 BaseTypedef1;
typedef struct BaseStruct2 BaseTypedef2;

enum BaseEnum{
    BASE_ENUM_1,
    BASE_ENUM_2,
};

#define BASE_MACRO_1 1;

void base_func1(BaseTypedef1 t1, BaseTypedef2 t2);
