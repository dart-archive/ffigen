// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct struc
{
    void (*unnamed1)(void (*unnamed2)());
};

void func(void (*unnamed1)(void (*unnamed2)()));
