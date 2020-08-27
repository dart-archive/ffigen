// Only this should be parsed.
enum{
    A=1,
    B=2, // This will be excluded by config.
    C=3
};

// Shouldn't be parsed.
typedef enum{
    E,
    F,
    G
} Named;
