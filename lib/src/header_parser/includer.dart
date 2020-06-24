// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'data.dart';

/// Utility functions to check whether a binding should be parsed or not
/// based on filters and if a binding is seen already.

// Stores binding names already scene.
Set<String> _structs = {};
Set<String> _functions = {};
Set<String> _enumClass = {};
Set<String> _typedefC = {};

bool shouldIncludeStruct(String name) {
  if (_structs.contains(name) || name == '') {
    return false;
  } else if (config.structFilters == null ||
      config.structFilters.shouldInclude(name)) {
    _structs.add(name);
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeFunc(String name) {
  if (_functions.contains(name) || name == '') {
    return false;
  } else if (config.functionFilters == null ||
      config.functionFilters.shouldInclude(name)) {
    _functions.add(name);
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeEnumClass(String name) {
  if (_enumClass.contains(name) || name == '') {
    return false;
  } else if (config.enumClassFilters == null ||
      config.enumClassFilters.shouldInclude(name)) {
    _enumClass.add(name);
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

bool isUnseenTypedefC(String name, {@required bool addToSeen}) {
  if (_typedefC.contains(name)) {
    return false;
  } else {
    if (addToSeen) {
      _typedefC.add(name);
    }
    return true;
  }
}

bool isUnseenStruct(String name, {@required bool addToSeen}) {
  if (_structs.contains(name)) {
    return false;
  } else {
    if (addToSeen) {
      _structs.add(name);
    }
    return true;
  }
}
