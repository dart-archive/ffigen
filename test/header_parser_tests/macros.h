#define TEST1 1.1
#define TEST2 10
#define TEST3 (TEST1 + TEST2)
#define TEST4 "test"

// This should have been ignored but is parsed as an int of value 1.
#define TEST5 4, \
              2, \
              3
#define TEST6 (1 == 1);
#define TEST7(x, y) x *y
