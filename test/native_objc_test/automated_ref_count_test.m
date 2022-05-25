// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface ArcTestObject : NSObject {
  int32_t* counter;
}

+ (instancetype)allocTheThing;
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
- (void)setCounter:(int32_t*) _counter;
- (void)dealloc;
- (ArcTestObject*)unownedReference;
- (ArcTestObject*)copyMe;
- (ArcTestObject*)makeACopy;
- (ArcTestObject*)returnsRetained NS_RETURNS_RETAINED;

@end

@implementation ArcTestObject

+ (instancetype)allocTheThing {
  return [ArcTestObject alloc];
}

+ (instancetype)newWithCounter:(int32_t*) _counter {
  return [[ArcTestObject alloc] initWithCounter: _counter];
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
  --*counter;
  [super dealloc];
}

- (ArcTestObject*)unownedReference {
  return self;
}

- (ArcTestObject*)copyMe {
  return [[ArcTestObject alloc] initWithCounter: counter];
}

- (ArcTestObject*)makeACopy {
  return [[ArcTestObject alloc] initWithCounter: counter];
}

- (ArcTestObject*)returnsRetained NS_RETURNS_RETAINED {
  return [self retain];
}

@end
