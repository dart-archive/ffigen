// Only this should be parsed.
enum{
    A=1,
    B=2,
    C=3
};

// Shouldn't be parsed.
typedef enum{
    E,
    F,
    G
} Named;
