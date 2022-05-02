#import <Foundation/NSObject.h>

@interface Thing : NSObject {}
-(int32_t)add:(int32_t)x Y:(int32_t) y;
@end

@implementation Thing
-(int32_t)add:(int32_t)x Y:(int32_t) y {
  return x + y;
}
@end

@interface Thing (Sub)
-(int32_t)sub:(int32_t)x Y:(int32_t) y;
@end

@implementation Thing (Sub)
-(int32_t)sub:(int32_t)x Y:(int32_t) y {
  return x - y;
}
@end
