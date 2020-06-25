// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A generic filter for filtering strings based on regexes and prefixes.
///
/// Excludes override includes.
///
/// User can provide fiters for functions, structs, enums and include/exclude
/// them using regexp and full name matching.
class Filter {
  // matchers
  List<RegExp> _includeMatchers = [];
  Set<String> _includeFull = {};
  List<RegExp> _excludeMatchers = [];
  Set<String> _excludeFull = {};

  Filter({
    List<String> includeMatchers,
    List<String> includeFull,
    List<String> excludeMatchers,
    List<String> excludeFull,
  }) {
    if (includeMatchers != null) {
      _includeMatchers =
          includeMatchers.map((e) => RegExp(e, dotAll: true)).toList();
    }
    if (includeFull != null) {
      _includeFull = includeFull.map((e) => e).toSet();
    }
    if (excludeMatchers != null) {
      _excludeMatchers =
          excludeMatchers.map((e) => RegExp(e, dotAll: true)).toList();
    }
    if (excludeFull != null) {
      _excludeFull = excludeFull.map((e) => e).toSet();
    }
  }

  /// Checks if a name is allowed by a filter.
  bool shouldInclude(String name) {
    if (_excludeFull.contains(name)) {
      return false;
    }

    for (final em in _excludeMatchers) {
      if (em.firstMatch(name)?.end == name.length) {
        return false;
      }
    }

    if (_includeFull.contains(name)) {
      return true;
    }

    for (final im in _includeMatchers) {
      if (im.firstMatch(name)?.end == name.length) {
        return true;
      }
    }

    // If user has provided 'include' field in the filter, then default
    // matching is false.
    if (_includeMatchers.isNotEmpty || _includeFull.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  String toString() {
    return ''' (includeFull, includeMatchers, excludeFull, excludeMatchers)
$_includeFull
$_includeMatchers
$_excludeFull
$_excludeMatchers
    ''';
  }
}
