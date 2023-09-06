#import <Foundation/NSObject.h>

typedef struct {
  double x;
  double y;
  double z;
  double w;
} Vec4;

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

-(Vec4)twiddleVec4Components:(Vec4)v;
-(float)addFloats:(float)x Y:(float) y;
-(double)addDoubles:(double)x Y:(double) y;

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

-(Vec4)twiddleVec4Components:(Vec4)v {
    Vec4 u;
    u.x = v.y;
    u.y = v.z;
    u.z = v.w;
    u.w = v.x;
    return u;
}

-(float)addFloats:(float)x Y:(float) y {
    return x + y;
}

-(double)addDoubles:(double)x Y:(double) y {
    return x + y;
}

@end
