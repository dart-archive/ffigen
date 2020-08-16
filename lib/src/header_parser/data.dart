// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffigen/src/code_generator.dart' show Constant;
import 'package:ffigen/src/config_provider.dart' show Config;
import 'package:meta/meta.dart';
import 'clang_bindings/clang_bindings.dart' show Clang;

import 'utils.dart';

/// Holds all Global shared variables.

/// Holds configurations.
Config get config => _config;
Config _config;

/// Holds clang functions.
Clang get clang => _clang;
Clang _clang;

// Tracks seen status for bindings
BindingsIndex get bindingsIndex => _bindingsIndex;
BindingsIndex _bindingsIndex;

/// Used for naming typedefs.
IncrementalNamer get incrementalNamer => _incrementalNamer;
IncrementalNamer _incrementalNamer;

/// Holds the unique id refering to this isolate.
///
/// Used by visitChildren_wrap to call the correct dart function from C.
// int get uid => Isolate.current.controlPort.;
final uid = Isolate.current.controlPort.nativePort;

/// Saved macros, Key: prefixedName, Value originalName.
Map<String, Macro> get savedMacros => _savedMacros;
Map<String, Macro> _savedMacros;

/// Saved unnamed EnumConstants.
List<Constant> get unnamedEnumConstants => _unnamedEnumConstants;
List<Constant> _unnamedEnumConstants;

void initializeGlobals({@required Config config, @required Clang clang}) {
  _config = config;
  _clang = clang;
  _incrementalNamer = IncrementalNamer();
  _savedMacros = {};
  _unnamedEnumConstants = [];
  _bindingsIndex = BindingsIndex();
}
