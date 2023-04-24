// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

struct IncompleteStruct;

struct BitField {
  int x:3;
  int y:12;
};

@interface BadMethodTestObject : NSObject {
}

- (struct IncompleteStruct)incompleteReturn;  // Skipped.
- (struct IncompleteStruct*)incompletePointerReturn;  // Not skipped.
- (int64_t)incompleteParam:(struct IncompleteStruct)x;  // Skipped.
- (int64_t)incompletePointerParam:(struct IncompleteStruct*)x;  // Not skipped.

- (struct BitField)bitFieldReturn;  // Skipped.
- (struct BitField*)bitFieldPointerReturn;  // Not skipped.
- (int64_t)bitFieldParam:(struct BitField)x;  // Skipped.
- (int64_t)bitFieldPointerParam:(struct BitField*)x;  // Not skipped.

@property struct BitField bitFieldProperty;  // Skipped.

@end

@implementation BadMethodTestObject

- (struct IncompleteStruct*)incompletePointerReturn {
  return (struct IncompleteStruct*)1234;
}

- (int64_t)incompletePointerParam:(struct IncompleteStruct*)x {
  return (int64_t)x;
}

- (struct BitField*)bitFieldPointerReturn {
  return (struct BitField*)5678;
}

- (int64_t)bitFieldPointerParam:(struct BitField*)x {
  return (int64_t)x;
}

@end
