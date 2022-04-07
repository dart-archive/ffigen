#import <Foundation/NSObject.h>

@interface Foo : NSObject {
  double doubleVal;
}

@property int32_t intVal;

+ (Foo*)makeFoo:(double)x;

- (int32_t)multiply:(BOOL)useIntVals withOtherFoo:(Foo*)other;

@end

@implementation Foo

+ (Foo*)makeFoo:(double)x {
  Foo* foo = [Foo new];
  foo->doubleVal = x;
  [foo setIntVal:((int32_t)x)];
  return foo;
}

- (int32_t)multiply:(BOOL)useIntVals withOtherFoo:(Foo*)other {
  if (useIntVals) {
    return [self intVal] * [other intVal];
  } else {
    return (int32_t)(self->doubleVal * other->doubleVal);
  }
}

@end
