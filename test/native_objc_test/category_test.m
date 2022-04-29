#import <Foundation/NSObject.h>

@interface Foo : NSObject {}
-(int32_t)add:(int32_t)x Y:(int32_t) y;
@end

@implementation Foo
-(int32_t)add:(int32_t)x Y:(int32_t) y {
  return x + y;
}
@end

@interface Foo (Sub)
-(int32_t)sub:(int32_t)x Y:(int32_t) y;
@end

@implementation Foo (Sub)
-(int32_t)sub:(int32_t)x Y:(int32_t) y {
  return x - y;
}
@end
