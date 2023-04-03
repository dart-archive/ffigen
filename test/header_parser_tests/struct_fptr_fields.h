// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

typedef int (*ArithmeticOperation)(int a, int b);

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
    // Function pointer through typedef
    ArithmeticOperation operation;
    // Pointer to function pointer
    void (**sortPtr)(int *array, int len);
    // Function pointer with a function pointer parameter
    void (*sortBy)(int *array, int len, int (*evaluator)(int x));
    // Function where few parameters are named. This should not
    // produce parameters in output.
    void (*improperlyDeclaredParams)(int a, int, char);
    // Function pointer with 2 function pointer parameters
    void (*sortByWithFallback)(int *array,
                               int (*primaryEvaluator)(int x),
                               int (*fallbackEvaluator)(int x));
    // Array of function pointers. Does not produce proper output right now.
    void (*manyFunctions[2])(char a, char b);
};

struct HasIncompleteArrayOfFunctionPointers
{
    // Doesn't work: This produces an opaque type right now.
    void (*functions[])(char a, char b);
};
