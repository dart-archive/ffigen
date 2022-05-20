// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface ArcTestObject : NSObject {
  int32_t* counter;
}

- (instancetype)initWithCounter:(int32_t*) _counter;
- (void)dealloc;
- (ArcTestObject*)unownedReference;

@end

@implementation ArcTestObject

- (instancetype)initWithCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
  return [super init];
}

- (void)dealloc {
  --*counter;
  [super dealloc];
}

- (ArcTestObject*)unownedReference {
  return self;
}

@end
