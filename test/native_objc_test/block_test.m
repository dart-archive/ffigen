// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSThread.h>

#include "util.h"

typedef struct {
  double x;
  double y;
  double z;
  double w;
} Vec4;

@interface DummyObject : NSObject {
  int32_t* counter;
}
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
- (void)setCounter:(int32_t*) _counter;
- (void)dealloc;
@end
@implementation DummyObject

+ (instancetype)newWithCounter:(int32_t*) _counter {
  return [[DummyObject alloc] initWithCounter: _counter];
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


typedef int32_t (^IntBlock)(int32_t);
typedef float (^FloatBlock)(float);
typedef double (^DoubleBlock)(double);
typedef Vec4 (^Vec4Block)(Vec4);
typedef void (^VoidBlock)();
typedef DummyObject* (^ObjectBlock)(DummyObject*);
typedef DummyObject* _Nullable (^NullableObjectBlock)(DummyObject* _Nullable);
typedef IntBlock (^BlockBlock)(IntBlock);

// Wrapper around a block, so that our Dart code can test creating and invoking
// blocks in Objective C code.
@interface BlockTester : NSObject {
  IntBlock myBlock;
}
+ (BlockTester*)makeFromBlock:(IntBlock)block;
+ (BlockTester*)makeFromMultiplier:(int32_t)mult;
- (int32_t)call:(int32_t)x;
- (IntBlock)getBlock;
- (void)pokeBlock;
+ (void)callOnSameThread:(VoidBlock)block;
+ (NSThread*)callOnNewThread:(VoidBlock)block;
+ (float)callFloatBlock:(FloatBlock)block;
+ (double)callDoubleBlock:(DoubleBlock)block;
+ (Vec4)callVec4Block:(Vec4Block)block;
+ (DummyObject*)callObjectBlock:(ObjectBlock)block NS_RETURNS_RETAINED;
+ (nullable DummyObject*)callNullableObjectBlock:(NullableObjectBlock)block;
+ (IntBlock)newBlock:(BlockBlock)block withMult:(int)mult;
+ (BlockBlock)newBlockBlock:(int)mult;
@end

@implementation BlockTester
+ (BlockTester*)makeFromBlock:(IntBlock)block {
  BlockTester* bt = [BlockTester new];
  bt->myBlock = block;
  return bt;
}

+ (BlockTester*)makeFromMultiplier:(int32_t)mult {
  BlockTester* bt = [BlockTester new];
  bt->myBlock = [^int32_t(int32_t x) {
    return x * mult;
  } copy];
  return bt;
}

- (int32_t)call:(int32_t)x {
  return myBlock(x);
}

- (IntBlock)getBlock {
  return myBlock;
}

- (void)pokeBlock {
  // Used to repro https://github.com/dart-lang/ffigen/issues/376
  [[myBlock retain] release];
}

+ (void)callOnSameThread:(VoidBlock)block {
  block();
}

+ (NSThread*)callOnNewThread:(VoidBlock)block {
  return [[NSThread alloc] initWithBlock: block];
}

+ (float)callFloatBlock:(FloatBlock)block {
  return block(1.23);
}

+ (double)callDoubleBlock:(DoubleBlock)block {
  return block(1.23);
}

+ (Vec4)callVec4Block:(Vec4Block)block {
  Vec4 vec4;
  vec4.x = 1.2;
  vec4.y = 3.4;
  vec4.z = 5.6;
  vec4.w = 7.8;
  return block(vec4);
}

+ (DummyObject*)callObjectBlock:(ObjectBlock)block NS_RETURNS_RETAINED {
  return block([DummyObject new]);
}

+ (nullable DummyObject*)callNullableObjectBlock:(NullableObjectBlock)block {
  return block(nil);
}

+ (IntBlock)newBlock:(BlockBlock)block withMult:(int)mult {
  return block([^int(int x) {
    return mult * x;
  } copy]);
  // ^ copy this stack allocated block to the heap.
}

+ (BlockBlock)newBlockBlock:(int)mult {
  return [^IntBlock(IntBlock block) {
    return [^int(int x) {
      return mult * block(x);
    } copy];
  } copy];
}

@end
