// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface BaseClass : NSObject {}
+ (instancetype)create;
- (instancetype)getSelf;
@end

@interface ChildClass : BaseClass {}
@property int32_t field;
@end

@implementation BaseClass
+ (instancetype)create {
  return [[[self class] alloc] init];
}

- (instancetype)getSelf {
  return self;
}
@end

@implementation ChildClass
- (instancetype)init {
  if (self = [super init]) {
    self.field = 123;
  }
  return self;
}
@end
