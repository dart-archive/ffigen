// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'foo_bindings.dart';

void main(List<String> args) {
  final lib = FooLibrary(DynamicLibrary.open(
    'libfoo.dylib'
    // '/Users/liama/Library/Developer/Xcode/DerivedData/swift_test-dpwgcflhtfzmljgepsjrlrrmohzo/Build/Products/Debug-maccatalyst/swift_test.framework/swift_test'
  ));
  final foo = FooClass.new1(lib);
  print(foo.getValue());
  foo.setValueWithX_(456);
  print(foo.getValue());
  print(NSObject.new1(lib));
}
