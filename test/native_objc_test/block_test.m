// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSThread.h>

typedef struct {
  double x;
  double y;
  double z;
  double w;
} Vec4;

typedef int32_t (^IntBlock)(int32_t);
typedef float (^FloatBlock)(float);
typedef double (^DoubleBlock)(double);
typedef Vec4 (^Vec4Block)(Vec4);
typedef void (^VoidBlock)();

// Wrapper around a block, so that our Dart code can test creating and invoking
// blocks in Objective C code.
@interface BlockTester : NSObject {
  IntBlock myBlock;
}
+ (BlockTester*)makeFromBlock:(IntBlock)block;
+ (BlockTester*)makeFromMultiplier:(int32_t)mult;
+ (uint64_t)getBlockRetainCount:(void*)block;
- (int32_t)call:(int32_t)x;
- (IntBlock)getBlock;
- (void)pokeBlock;
+ (void)callOnSameThread:(VoidBlock)block;
+ (NSThread*)callOnNewThread:(VoidBlock)block;
+ (float)callFloatBlock:(FloatBlock)block;
+ (double)callDoubleBlock:(DoubleBlock)block;
+ (Vec4)callVec4Block:(Vec4Block)block;
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

typedef struct {
  void* isa;
  int flags;
  // There are other fields, but we just need the flags and isa.
} BlockRefCountExtractor;

void* valid_block_isa = NULL;
+ (uint64_t)getBlockRetainCount:(void*)block {
  BlockRefCountExtractor* b = (BlockRefCountExtractor*)block;
  // HACK: The only way I can find to reliably figure out that a block has been
  // deleted is to check the isa field (the lower bits of the flags field seem
  // to be randomized, not just set to 0). But we also don't know the value this
  // field has when it's constructed (copying the block changes it from
  // _NSConcreteGlobalBlock to an internal value). So we assume that the first
  // time this function is called, we have a valid block, and on subsequent
  // calls we check to see if the isa field changed.
  if (valid_block_isa == NULL) {
    valid_block_isa = b->isa;
  }
  if (b->isa != valid_block_isa) {
    return 0;
  }
  // The ref count is stored in the lower bits of the flags field, but skips the
  // 0x1 bit.
  return (b->flags & 0xFFFF) >> 1;
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

@end
