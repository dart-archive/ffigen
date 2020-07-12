struct Struct1
{
    int a;
};

struct Struct2
{
    struct Struct1 a;
};

void func1(struct Struct2 *s);
