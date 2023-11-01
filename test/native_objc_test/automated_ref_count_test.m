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

@property (assign) ArcTestObject* assignedProperty;
@property (retain) ArcTestObject* retainedProperty;
@property (copy) ArcTestObject* copiedProperty;

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
  [_retainedProperty release];
  [_copiedProperty release];
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

// Pass around the NSAutoreleasePool as a void* to bypass the Dart wrappers so
// that we can precisely control the life cycle.
void* createAutoreleasePool() {
  return (void*)[NSAutoreleasePool new];
}

void destroyAutoreleasePool(void* pool) {
  [((NSAutoreleasePool*)pool) release];
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
