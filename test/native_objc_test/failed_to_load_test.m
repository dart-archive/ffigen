// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface ClassThatWillFailToLoad : NSObject {}
-(int32_t)get123;
@end

@implementation ClassThatWillFailToLoad
-(int32_t)get123 {
  return 123;
}
@end
