#import <Foundation/NSObject.h>

@interface MethodInterface : NSObject {
}


-(int32_t)add;
-(int32_t)add:(int32_t)x;
-(int32_t)add:(int32_t)x Y:(int32_t) y;
-(int32_t)add:(int32_t)x Y:(int32_t) y Z:(int32_t) z;

+(int32_t)sub;
+(int32_t)sub:(int32_t)x;
+(int32_t)sub:(int32_t)x Y:(int32_t) y;
+(int32_t)sub:(int32_t)x Y:(int32_t) y Z:(int32_t) z;

@end

@implementation MethodInterface

-(int32_t)add {
  return 5;
}

-(int32_t)add:(int32_t)x {
    return x;
}

-(int32_t)add:(int32_t)x Y:(int32_t) y {
    return x + y;
}

-(int32_t)add:(int32_t)x Y:(int32_t) y Z:(int32_t) z {
    return x + y + z;
}

+(int32_t)sub {
  return -5;
}

+(int32_t)sub:(int32_t)x {
    return -x;
}

+(int32_t)sub:(int32_t)x Y:(int32_t) y {
    return -x - y;
}

+(int32_t)sub:(int32_t)x Y:(int32_t) y Z:(int32_t) z {
    return - x - y - z;
}

@end
