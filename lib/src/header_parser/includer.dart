// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'data.dart';

/// Utility functions to check whether a binding should be parsed or not
/// based on filters.

bool shouldIncludeStruct(String usr, String name) {
  if (bindingsIndex.isSeenStruct(usr) || name == '') {
    return false;
  } else if (config.structDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeUnion(String usr, String name) {
  if (bindingsIndex.isSeenStruct(usr) || name == '') {
    return false;
  } else if (config.unionDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeFunc(String usr, String name) {
  if (bindingsIndex.isSeenFunc(usr) || name == '') {
    return false;
  } else if (config.functionDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeEnumClass(String usr, String name) {
  if (bindingsIndex.isSeenEnumClass(usr) || name == '') {
    return false;
  } else if (config.enumClassDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeUnnamedEnumConstant(String usr, String name) {
  if (bindingsIndex.isSeenUnnamedEnumConstant(usr) || name == '') {
    return false;
  } else if (config.unnamedEnumConstants.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeGlobalVar(String usr, String name) {
  if (bindingsIndex.isSeenGlobalVar(usr) || name == '') {
    return false;
  } else if (config.globals.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeMacro(String usr, String name) {
  if (bindingsIndex.isSeenMacro(usr) || name == '') {
    return false;
  } else if (config.macroDecl.shouldInclude(name)) {
    return true;
  } else {
    return false;
  }
}

/// Cache for headers.
final _headerCache = <String, bool>{};

/// True if a cursor should be included based on headers config, used on root
/// declarations.
bool shouldIncludeRootCursor(String sourceFile) {
  // Handle empty string in case of system headers or macros.
  if (sourceFile.isEmpty) {
    return false;
  }

  // Add header to cache if its not.
  if (!_headerCache.containsKey(sourceFile)) {
    _headerCache[sourceFile] =
        config.headers.includeFilter.shouldInclude(sourceFile);
  }

  return _headerCache[sourceFile]!;
}
