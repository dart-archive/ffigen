#import <Foundation/NSObject.h>

@interface NullableInterface  : NSObject {
}

+(BOOL) isNullWithNullableNSObjectArg:(nullable NSObject *)x;
+(BOOL) isNullWithNotNullableNSObjectPtrArg:(NSObject *)x;
+(BOOL) isNullWithExplicitNonNullableNSObjectPtrArg:(nonnull NSObject *)x;
+(nullable NSObject *) returnNil:(BOOL)r;

@property (nullable, retain) NSObject *nullableObjectProperty;

@end

@implementation NullableInterface

+(BOOL) isNullWithNullableNSObjectArg:(nullable NSObject *)x {
  return x == NULL;
}

+(BOOL) isNullWithNotNullableNSObjectPtrArg:(NSObject *)x {
  return x == NULL;
}

+(BOOL) isNullWithExplicitNonNullableNSObjectPtrArg:(nonnull NSObject *)x {
  return x == NULL;
}

+(nullable NSObject *) returnNil:(BOOL)r {
  if (r) {
    return nil;
  } else {
    return [NSObject new];
  }
}

@end
