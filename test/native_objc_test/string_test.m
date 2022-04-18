#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

// TODO(#309): strConcat should just be a static function.
@interface StringUtil : NSObject {}
+ (NSString*)strConcat:(NSString*)a with:(NSString*)b;
@end

@implementation StringUtil
+ (NSString*)strConcat:(NSString*)a with:(NSString*)b {
  return [a stringByAppendingString:b];
}
@end
