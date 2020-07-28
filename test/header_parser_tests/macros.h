#define TEST1 1.1
#define TEST2 10
#define TEST3 (TEST1 + TEST2)
#define TEST4 "test"

// The macro variable for this generated wouldn't compile, but libclang assigns
// it a value of 4.
#define TEST5 4, \
              2, \
              3
#define TEST6 (1 == 1);
#define TEST7(x, y) x *y

// The macro variable for this generated wouldn't compile, but libclang assigns
// it a value of 5.
#define TEST8 5,2,3
