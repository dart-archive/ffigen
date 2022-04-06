struct Foo {
  BOOL someBool;
  id anId;
  SEL selector;
  NSObject* object;
  Class clazz;
  int32_t (^blockThatReturnsAnInt)(void);
};
