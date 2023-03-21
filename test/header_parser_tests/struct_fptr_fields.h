// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct S
{
    // Function pointer field, but no parameters.
    int (*func1)(void);
    // Function pointer field with parameters.
    int (*comparator)(int a, int b);
    // Function pointer field with lot of parameters
    int (*veryManyArguments)(double a, float b, char *c, int d, long long e);
    // Function pointer field with parameters, but no names
    int (*argsDontHaveNames)(int, int, int, float, char *);
};

