// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSAutoreleasePool.h>

@interface ArcTestObject : NSObject {
  int32_t* counter;
}

+ (instancetype)allocTheThing;
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
+ (ArcTestObject*)makeAndAutorelease:(int32_t*) _counter;
- (void)setCounter:(int32_t*) _counter;
- (void)dealloc;
- (ArcTestObject*)unownedReference;
- (ArcTestObject*)copyMe;
- (ArcTestObject*)makeACopy;
- (id)copyWithZone:(NSZone*) zone;
- (ArcTestObject*)returnsRetained NS_RETURNS_RETAINED;

@end

@interface RefCounted : NSObject

@property(readonly) uint64_t refCount;

- (int64_t) meAsInt;

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

+ (instancetype)makeAndAutorelease:(int32_t*) _counter {
  return [[[ArcTestObject alloc] initWithCounter: _counter] autorelease];
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

- (id)copyWithZone:(NSZone*) zone {
  return [[ArcTestObject alloc] initWithCounter: counter];
}

- (ArcTestObject*)returnsRetained NS_RETURNS_RETAINED {
  return [self retain];
}

@end

id createAutoreleasePool() {
  return [NSAutoreleasePool new];
}

void destroyAutoreleasePool(id pool) {
  [pool release];
}

@implementation RefCounted

- (instancetype)init {
    if (self = [super init]) {
      self->_refCount = 1;
    }
    return self;
}

- (instancetype)retain {
  ++self->_refCount;
  return self;
}

- (oneway void)release {
  --self->_refCount;
  if (self->_refCount == 0) {
    [self dealloc];
  }
}

- (int64_t) meAsInt {
  return (int64_t) self;
}

@end
