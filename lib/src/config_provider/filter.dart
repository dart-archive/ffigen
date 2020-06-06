class Filter {
  /// matchers
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

  /// Checks if a name should be included based on config
  bool shouldInclude(String name) {
    if (_excludeFull.contains(name)) {
      return false;
    }

    for (var em in _excludeMatchers) {
      if (em.firstMatch(name)?.end == name.length) {
        return false;
      }
    }

    if (_includeFull.contains(name)) {
      return true;
    }

    for (var im in _includeMatchers) {
      if (im.firstMatch(name)?.end == name.length) {
        return true;
      }
    }

    // if user has provided what to include, then by default match is false
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
