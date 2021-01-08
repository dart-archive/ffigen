// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffigen/src/code_generator.dart' show Constant;
import 'package:ffigen/src/config_provider.dart' show Config;
import 'clang_bindings/clang_bindings.dart' show Clang;

import 'utils.dart';

/// Holds all Global shared variables.

/// Holds configurations.
Config get config => _config;
late Config _config;

/// Holds clang functions.
Clang get clang => _clang;
late Clang _clang;

// Tracks seen status for bindings
BindingsIndex get bindingsIndex => _bindingsIndex;
BindingsIndex _bindingsIndex = BindingsIndex();

/// Used for naming typedefs.
IncrementalNamer get incrementalNamer => _incrementalNamer;
IncrementalNamer _incrementalNamer = IncrementalNamer();

/// Saved macros, Key: prefixedName, Value originalName.
Map<String, Macro> get savedMacros => _savedMacros;
Map<String, Macro> _savedMacros = {};

/// Saved unnamed EnumConstants.
List<Constant> get unnamedEnumConstants => _unnamedEnumConstants;
List<Constant> _unnamedEnumConstants = [];

void initializeGlobals({required Config config}) {
  _config = config;
  _clang = Clang(DynamicLibrary.open(config.libclangDylib));
  _incrementalNamer = IncrementalNamer();
  _savedMacros = {};
  _unnamedEnumConstants = [];
  _bindingsIndex = BindingsIndex();
}
