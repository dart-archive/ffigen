// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

int32_t totalObjects = 0;

@interface ArcTestObject : NSObject {}

+ (int32_t)getTotalObjects;
- (instancetype)init;
- (void)dealloc;

@end

@implementation ArcTestObject

+ (int32_t)getTotalObjects {
  return totalObjects;
}

- (instancetype)init {
  ++totalObjects;
  return [super init];
}

- (void)dealloc {
  --totalObjects;
  [super dealloc];
}

@end
