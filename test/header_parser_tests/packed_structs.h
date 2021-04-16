// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct NormalStruct1
{
    char a;
};

/// Should not be packed.
struct StructWithAttr
{
    int *a;
    int *b;
} __attribute__((annotate("Attr is not __packed__")));

/// Should be packed with 1.
struct PackedAttr{
    int a;
} __attribute__((__packed__));

/// Should be packed with 8.
struct PackedAttrAlign8{
    int a;
} __attribute__((__packed__, aligned(8)));

#pragma pack(push, 2)
/// Should be packed with 2.
struct Pack2WithPragma{
    int a;
};
#pragma pack(4)
/// Should be packed with 4.
struct Pack4WithPragma{
    long long a;
};
#pragma pack(pop)
struct NormalStruct2
{
    char a;
};
