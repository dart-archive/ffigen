// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

/// Represents a native unsigned pointer-sized integer in C.
///
/// [UintPtr] is not constructible in the Dart code and serves purely as marker in
/// type signatures.
@AbiSpecificIntegerMapping({
  Abi.androidArm: Uint32(),
  Abi.androidArm64: Uint64(),
  Abi.androidIA32: Uint32(),
  Abi.androidX64: Uint64(),
  Abi.fuchsiaArm64: Uint64(),
  Abi.fuchsiaX64: Uint64(),
  Abi.iosArm: Uint32(),
  Abi.iosArm64: Uint64(),
  Abi.iosX64: Uint64(),
  Abi.linuxArm: Uint32(),
  Abi.linuxArm64: Uint64(),
  Abi.linuxIA32: Uint32(),
  Abi.linuxX64: Uint64(),
  Abi.macosArm64: Uint64(),
  Abi.macosX64: Uint64(),
  Abi.windowsArm64: Uint64(),
  Abi.windowsIA32: Uint32(),
  Abi.windowsX64: Uint64(),
})
class UintPtr extends AbiSpecificInteger {
  const UintPtr();
}

/// `unsigned long` in C.
///
/// [UnsignedLong] is not constructible in the Dart code and serves purely as marker in
/// type signatures.
@AbiSpecificIntegerMapping({
  Abi.androidArm: Uint32(),
  Abi.androidArm64: Uint64(),
  Abi.androidIA32: Uint32(),
  Abi.androidX64: Uint64(),
  Abi.fuchsiaArm64: Uint64(),
  Abi.fuchsiaX64: Uint64(),
  Abi.iosArm: Uint32(),
  Abi.iosArm64: Uint64(),
  Abi.iosX64: Uint64(),
  Abi.linuxArm: Uint32(),
  Abi.linuxArm64: Uint64(),
  Abi.linuxIA32: Uint32(),
  Abi.linuxX64: Uint64(),
  Abi.macosArm64: Uint64(),
  Abi.macosX64: Uint64(),
  Abi.windowsArm64: Uint32(),
  Abi.windowsIA32: Uint32(),
  Abi.windowsX64: Uint32(),
})
class UnsignedLong extends AbiSpecificInteger {
  const UnsignedLong();
}

class CXCursorSetImpl extends Opaque {}
