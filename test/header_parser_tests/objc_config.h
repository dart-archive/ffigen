// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface Foo : NSObject {}
@end

@interface Excluded : NSObject {}
@end

@interface _Renamed : NSObject {}
@end
