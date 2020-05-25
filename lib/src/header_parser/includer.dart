import 'data.dart';

/// Utility to check whether a binding should be parsed or not

// Stores binding names already scene
Set<String> _structs = {};
Set<String> _functions = {};
Set<String> _enumClass = {};

bool shouldIncludeStruct(String name) {
  if (_structs.contains(name) || name == '') {
    return false;
  } else if (config.structFilters == null) {
    return true;
  } else if (config.structFilters.shouldInclude(name)) {
    _structs.add(name);
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeFunc(String name) {
  if (_functions.contains(name) || name == '') {
    return false;
  } else if (config.functionFilters == null) {
    return true;
  } else if (config.functionFilters.shouldInclude(name)) {
    _functions.add(name);
    return true;
  } else {
    return false;
  }
}

bool shouldIncludeEnumClass(String name) {
  if (_enumClass.contains(name) || name == '') {
    return false;
  } else if (config.enumClassFilters == null) {
    return true;
  } else if (config.enumClassFilters.shouldInclude(name)) {
    _enumClass.add(name);
    return true;
  } else {
    return false;
  }
}
