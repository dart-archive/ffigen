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

@interface Thing (Mul)
-(int32_t)mul:(int32_t)x Y:(int32_t) y;

@property (readonly) int32_t someProperty;
@end

@implementation Thing (Mul)
-(int32_t)mul:(int32_t)x Y:(int32_t) y {
  return x * y;
}

-(int32_t)someProperty {
  return 456;
}
@end
