// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@interface Foo : NSObject {
  double doubleVal;
}

@property int32_t intVal;
@property BOOL boolVal;
@property id idVal;
@property SEL selVal;
@property NSObject* objVal;
@property Class classVal;

+ (Foo*)makeFoo:(double)x;

- (int32_t)multiply:(BOOL)useIntVals withOtherFoo:(Foo*)other;

- (void)setDoubleVal:(double)x;

@end

@implementation Foo

+ (Foo*)makeFoo:(double)x {
  Foo* foo = [Foo new];
  foo->doubleVal = x;
  [foo setIntVal:((int32_t)x)];
  return foo;
}

- (int32_t)multiply:(BOOL)useIntVals withOtherFoo:(Foo*)other {
  if (useIntVals) {
    return [self intVal] * [other intVal];
  } else {
    return (int32_t)(self->doubleVal * other->doubleVal);
  }
}

- (void)setDoubleVal:(double)x {
  self->doubleVal = x;
}

@end
