// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility functions to check whether a binding should be parsed or not
/// based on filters.

import 'data.dart';

bool _shouldIncludeDecl(String usr, String name,
    bool Function(String) isSeenDecl, bool Function(String) configIncludes) {
  if (isSeenDecl(usr) || name == '') {
    return false;
  } else if (configIncludes(name)) {
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeStruct(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenStruct, config.structDecl.shouldInclude);
}

bool shouldIncludeUnion(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenUnion, config.unionDecl.shouldInclude);
}

bool shouldIncludeFunc(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenFunc, config.functionDecl.shouldInclude);
}

bool shouldIncludeEnumClass(String usr, String name) {
  return _shouldIncludeDecl(usr, name, bindingsIndex.isSeenEnumClass,
      config.enumClassDecl.shouldInclude);
}

bool shouldIncludeUnnamedEnumConstant(String usr, String name) {
  return _shouldIncludeDecl(usr, name, bindingsIndex.isSeenUnnamedEnumConstant,
      config.unnamedEnumConstants.shouldInclude);
}

bool shouldIncludeGlobalVar(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenGlobalVar, config.globals.shouldInclude);
}

bool shouldIncludeMacro(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenMacro, config.macroDecl.shouldInclude);
}

bool shouldIncludeTypealias(String usr, String name) {
  return _shouldIncludeDecl(
      usr, name, bindingsIndex.isSeenTypealias, config.typedefs.shouldInclude);
}

/// True if a cursor should be included based on headers config, used on root
/// declarations.
bool shouldIncludeRootCursor(String sourceFile) {
  // Handle empty string in case of system headers or macros.
  if (sourceFile.isEmpty) {
    return false;
  }

  // Add header to seen if it's not.
  if (!bindingsIndex.isSeenHeader(sourceFile)) {
    bindingsIndex.addHeaderToSeen(
        sourceFile, config.headers.includeFilter.shouldInclude(sourceFile));
  }

  return bindingsIndex.getSeenHeaderStatus(sourceFile)!;
}
