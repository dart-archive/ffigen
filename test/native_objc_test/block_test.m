// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

typedef int32_t (^IntBlock)(int32_t);

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
@end
