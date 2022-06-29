// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

struct IncompleteStruct;

@interface BadMethodTestObject : NSObject {
}

- (struct IncompleteStruct)incompleteReturn;  // Skipped.
- (struct IncompleteStruct*)incompletePointerReturn;  // Not skipped.
- (int64_t)incompleteParam:(struct IncompleteStruct)x;  // Skipped.
- (int64_t)incompletePointerParam:(struct IncompleteStruct*)x;  // Not skipped.

@end

@implementation BadMethodTestObject

- (struct IncompleteStruct*)incompletePointerReturn {
  return (struct IncompleteStruct*)1234;
}

- (int64_t)incompletePointerParam:(struct IncompleteStruct*)x {
  return (int64_t)x;
}

@end
