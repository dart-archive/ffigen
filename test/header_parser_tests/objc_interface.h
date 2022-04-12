// This is the Foo interface.
@interface Foo : NSObject {
  // This is an instance variable. They are private, so are ignored.
  double instVar;
}

// This is a property. We generate getters and setters for them.
@property int32_t someProperty;

// This should only generate a getter.
@property (readonly) int32_t readOnlyProperty;

// This should only generate a getter static function.
@property (class, readonly) int32_t classReadOnlyProperty;

// This should generate getter and setter static functions.
@property (class) int32_t classReadWriteProperty;

// This is a class method, so becomes a static function.
+ (Foo*)aClassMethod:(double)someArg;

// This is an instance method, so becomes a regular method.
- (int32_t)anInstanceMethod:(NSString*)someArg withOtherArg:(Foo*)otherArg;

@end
