// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface Castaway : NSObject {
}

- (NSObject *) meAsNSObject;
- (int64_t) meAsInt;

@end

@implementation Castaway

- (NSObject *) meAsNSObject {
  return self;
}

- (int64_t) meAsInt {
  return (int64_t) self;
}

@end
