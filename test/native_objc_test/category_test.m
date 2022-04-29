#import <Foundation/NSObject.h>

@interface Foo : NSObject {}
@end

@interface Foo (Add)
-(int32_t)add:(int32_t)x Y:(int32_t) y;
@end

@implementation Foo (Add)
-(int32_t)add:(int32_t)x Y:(int32_t) y {
  return x + y;
}
@end
