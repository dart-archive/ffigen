// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSString.h>

#include "util.h"

// Take and return object, nullable, and block
// ref counting tests

@interface StaticFuncTestObj : NSObject {
  int32_t* counter;
}
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
- (void)setCounter:(int32_t*) _counter;
- (void)dealloc;
@end
@implementation StaticFuncTestObj

+ (instancetype)newWithCounter:(int32_t*) _counter {
  return [[StaticFuncTestObj alloc] initWithCounter: _counter];
}

- (instancetype)initWithCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
  return [super init];
}

- (void)setCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
}

- (void)dealloc {
  if (counter != nil) --*counter;
  [super dealloc];
}

@end

StaticFuncTestObj* staticFuncOfObject(StaticFuncTestObj* a) {
  return a;
}

StaticFuncTestObj* _Nullable staticFuncOfNullableObject(
    StaticFuncTestObj* _Nullable a) {
  return a;
}

typedef int32_t (^IntBlock)(int32_t);
IntBlock staticFuncOfBlock(IntBlock a) {
  return a;
}

NSString* staticFuncReturningNSString() {
  return @"Hello World!";
}
