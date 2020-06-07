#include <stdint.h>

// Simple tests with primitives
void func1();
int32_t func2(int16_t);
double func3(float, int8_t a, int64_t, int32_t b);

// Tests with pointers to primitives
void *func4(int8_t **, double, int32_t ***);
