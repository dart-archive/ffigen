// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface BaseClass : NSObject {}
@end

@interface ChildClass : BaseClass {}
@end

@interface UnrelatedClass : NSObject {}
@end

@implementation BaseClass
@end

@implementation ChildClass
@end

@implementation UnrelatedClass
@end
