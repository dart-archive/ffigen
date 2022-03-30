// This is the Foo interface.
@interface Foo : NSObject {
  // This is an instance variable. They are private, so are ignored.
  double instVar;
}

// This is a property. We generate getters and setters for them.
@property int32_t someProperty;

// This is a class method, so becomes a static function.
+ (Foo*)aClassMethod:(double)someArg;

// This is an instance method, so becomes a regular method.
- (int32_t)anInstanceMethod:(NSString*)someArg withOtherArg:(Foo*)otherArg;

@end
