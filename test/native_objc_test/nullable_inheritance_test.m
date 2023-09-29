#import <Foundation/NSObject.h>

@interface NullableBase : NSObject {}

-(BOOL) nullableArg:(nullable NSObject *)x;
-(BOOL) nonNullArg:(NSObject *)x;
-(nullable NSObject *) nullableReturn:(BOOL)r;
-(NSObject*) nonNullReturn;

@end

@implementation NullableBase

-(BOOL) nullableArg:(nullable NSObject *)x {
  return x == NULL;
}

-(BOOL) nonNullArg:(NSObject *)x {
  return x == NULL;
}

-(nullable NSObject *) nullableReturn:(BOOL)r {
  if (r) {
    return nil;
  } else {
    return [NSObject new];
  }
}

-(NSObject *) nonNullReturn {
  return [NSObject new];
}

@end

@interface NullableIntermediate : NullableBase {}
@end
@implementation NullableIntermediate
@end

@interface NullableChild : NullableIntermediate {}

// Redeclare the same methods with different nullability.
-(BOOL) nullableArg:(NSObject *)x;
-(BOOL) nonNullArg:(nullable NSObject *)x;
-(NSObject *) nullableReturn:(BOOL)r;
-(nullable NSObject *) nonNullReturn;

@end

@implementation NullableChild

-(BOOL) nullableArg:(NSObject *)x {
  return x == NULL;
}

-(BOOL) nonNullArg:(nullable NSObject *)x {
  return x == NULL;
}

-(NSObject *) nullableReturn:(BOOL)r {
  return [NSObject new];
}

-(nullable NSObject *) nonNullReturn {
  return nil;
}

@end
