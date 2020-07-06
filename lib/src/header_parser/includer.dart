// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:path/path.dart' as p;
import 'data.dart';

/// Utility functions to check whether a binding should be parsed or not
/// based on filters.

// Stores binding names already scene. Mp key is same as their original name.
Map<String, Struc> _structs = {};
Map<String, Func> _functions = {};
Map<String, EnumClass> _enumClass = {};

bool shouldIncludeStruct(String name) {
  if (_structs.containsKey(name) || name == '') {
    return false;
  } else if (config.structDecl == null ||
      config.structDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeFunc(String name) {
  if (_functions.containsKey(name) || name == '') {
    return false;
  } else if (config.functionDecl == null ||
      config.functionDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeEnumClass(String name) {
  if (_enumClass.containsKey(name) || name == '') {
    return false;
  } else if (config.enumClassDecl == null ||
      config.enumClassDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

/// True if a cursor should be included based on header-filter, use for root
/// declarations.
bool shouldIncludeRootCursor(String sourceFile) {
  final name = p.basename(sourceFile);

  if (config.headerFilter.excludedInclusionHeaders.contains(name)) {
    return false;
  }

  if (config.headerFilter.includedInclusionHeaders.contains(name)) {
    return true;
  }

  // If any includedInclusionHeaders is provided, return false.
  if (config.headerFilter.includedInclusionHeaders.isNotEmpty) {
    return false;
  } else {
    return true;
  }
}

bool isSeenStruc(String originalName) {
  return _structs.containsKey(originalName);
}

void addStrucToSeen(String originalName, Struc struc) {
  _structs[originalName] = struc;
}

Struc getSeenStruc(String originalName) {
  return _structs[originalName];
}

bool isSeenFunc(String originalName) {
  return _functions.containsKey(originalName);
}

void addFuncToSeen(String originalName, Func func) {
  _functions[originalName] = func;
}

Func getSeenFunc(String originalName) {
  return _functions[originalName];
}

bool isSeenEnumClass(String originalName) {
  return _enumClass.containsKey(originalName);
}

void addEnumClassToSeen(String originalName, EnumClass enumClass) {
  _enumClass[originalName] = enumClass;
}

EnumClass getSeenEnumClass(String originalName) {
  return _enumClass[originalName];
}
