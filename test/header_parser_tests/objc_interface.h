@interface Foo : NSObject {
  double instVar;
}
@property int32_t someProperty;

+ (Foo*)aClassMethod:(double)someArg;

- (int32_t)anInstanceMethod:(NSString*)someArg withOtherArg:(Foo*)otherArg;

@end
