#include<math.h>

#define TEST1 1.1
#define TEST2 10
#define TEST3 (TEST1 + TEST2)
#define TEST4 "test"

// The comma operator should actually return the last value (3),
// when returned by a function. This value, however, when assigned to a variable
// will not compile and so libclang tries to fix it and assigns the first
// value (4) to the generated macro variable.
#define TEST5 4, \
              2, \
              3
#define TEST6 (1 == 1);
#define TEST7(x, y) x *y

#define TEST8 5,2,3

// These test that special characters are escaped properly.
#define TEST9 "$dollar"
#define TEST10 "test's"

// These test that extended ASCII and control characters are handled properly.
#define TEST11 "\x80"
#define TEST12 "hello\n\t\r\v\b"
#define TEST13 "test\\"

// Infinity, NaN and Negative Infinity.
#define TEST14 INFINITY
#define TEST15 -INFINITY
#define TEST16 NAN
