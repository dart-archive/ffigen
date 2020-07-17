// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffigen/src/config_provider.dart';
import 'clang_bindings/clang_bindings.dart' show Clang;

/// Holds all Global shared variables.

/// Holds configurations.
Config config;

/// Holds clang functions.
Clang clang;

/// Holds the unique id refering to this isolate.
///
/// Used by visitChildren_wrap to call the correct dart function from C.
// int get uid => Isolate.current.controlPort.;
final uid = Isolate.current.controlPort.nativePort;
