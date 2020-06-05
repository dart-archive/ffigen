import 'package:meta/meta.dart';

import 'data.dart';

/// Utility to check whether a binding should be parsed or not

// Stores binding names already scene
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

/// Returns if cursor should be included based on
/// header-exclusions, for used in root_parser
bool shouldIncludeRootCursor(String sourceFile) {
  String name = sourceFile.split('/').last;

  if (config.excludedInclusionHeaders.contains(name)) {
    return false;
  }

  if (config.includedInclusionHeaders.contains(name)) {
    return true;
  }

  // If any includedInclusionHeaders is provided, return false
  if (config.includedInclusionHeaders.length > 0) {
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
