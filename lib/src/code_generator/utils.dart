class UniqueNamer {
  final Set<String> _usedUpNames;
  UniqueNamer(this._usedUpNames);

  /// Returns a unique name by appending `_<int>` to it if necessary.
  ///
  /// Adds the resulting name to the used names by default.
  String makeUnique(String name, [bool addToUsedUpNames = true]) {
    String cr_name = name;
    int i = 1;
    while (_usedUpNames.contains(cr_name)) {
      cr_name = '${name}_$i';
      i++;
    }
    if (addToUsedUpNames) {
      _usedUpNames.add(cr_name);
    }
    return cr_name;
  }

  /// Adds a name to used names.
  ///
  /// Note: [makeUnique] also adds the name by default.
  void markUsed(String name) {
    _usedUpNames.add(name);
  }

  /// Returns true if a name has been used before.
  bool isUsed(String name) {
    return _usedUpNames.contains(name);
  }

  /// Returns true if a name has not been used before.
  bool isUnique(String name) {
    return !_usedUpNames.contains(name);
  }
}
