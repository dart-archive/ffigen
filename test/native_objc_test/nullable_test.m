#import <Foundation/NSObject.h>

@interface NullableInterface  : NSObject {
}

+(BOOL) isNullWithNullableNSObjectArg:(nullable NSObject *)x;
+(BOOL) isNullWithNotNullableNSObjectPtrArg:(NSObject *)x;

@end

@implementation NullableInterface

+(BOOL) isNullWithNullableNSObjectArg:(nullable NSObject *)x {
  return x == NULL;
}

+(BOOL) isNullWithNotNullableNSObjectPtrArg:(NSObject *)x {
  return x == NULL;
}

@end
